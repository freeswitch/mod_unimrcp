ARG BUILDER_IMAGE=arm64v8/debian:trixie-20250811

FROM --platform=${BUILDPLATFORM} ${BUILDER_IMAGE} AS builder

ARG MAINTAINER_NAME="Andrey Volk"
ARG MAINTAINER_EMAIL="andrey@signalwire.com"

ARG CODENAME=trixie

ARG BUILD_NUMBER=42
ARG GIT_SHA=0000000000

ARG DATA_DIR=/data

LABEL maintainer="${MAINTAINER_NAME} <${MAINTAINER_EMAIL}>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update \
    && apt-get -y -q install \
        apt-transport-https \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        debhelper \
        devscripts \
        dh-autoreconf \
        dos2unix \
        doxygen \
        dpkg-dev \
        git \
        gnupg2 \
        graphviz \
        libglib2.0-dev \
        libssl-dev \
        lsb-release \
        pkg-config \
        unzip \
        wget

RUN update-ca-certificates --fresh

RUN echo "export CODENAME=${CODENAME}" | tee ~/.env \
    && chmod +x ~/.env

RUN git config --global --add safe.directory '*' \
    && git config --global user.name "${MAINTAINER_NAME}" \
    && git config --global user.email "${MAINTAINER_EMAIL}"

RUN --mount=type=secret,id=REPO_PASSWORD,required=true \
    sha512sum /run/secrets/REPO_PASSWORD && \
    curl -sSL https://freeswitch.org/fsget | \
        bash -s $(cat /run/secrets/REPO_PASSWORD) prerelease && \
    apt-get --quiet update && \
    apt-get --yes --quiet install \
        libexpat1-dev \
        libfreeswitch-dev \
        libfreeswitch1 \
        libks2 \
        libsofia-sip-ua-dev \
        libspandsp3-dev \
        signalwire-client-c2 \
    && rm -f /etc/apt/auth.conf

# Bootstrap and Build
RUN wget -O - https://www.unimrcp.org/project/component-view/unimrcp-deps-1-6-0-tar-gz/download \
    | tar xvz -C /root

WORKDIR /root/unimrcp-deps-1.6.0/libs/apr
RUN CFLAGS="-fPIC -Wno-error=implicit-int -Wno-error=implicit-function-declaration" ./configure \
        --disable-shared \
        --enable-static \
        --prefix=/usr/local/apr \
    && make install

WORKDIR /root/unimrcp-deps-1.6.0/libs/apr-util
RUN CFLAGS="-fPIC -Wno-error=implicit-int -Wno-error=implicit-function-declaration" ./configure \
        --prefix=/usr/local/apr \
        --with-apr=/usr/local/apr \
        --with-expat=/usr \
    && make install

WORKDIR /root
RUN git clone https://github.com/unispeech/unimrcp.git

WORKDIR /root/unimrcp
RUN ./bootstrap \
    && ./configure \
        --with-sofia-sip=/usr \
    && make install

COPY . ${DATA_DIR}
WORKDIR ${DATA_DIR}

ENV UNIMRCP_CFLAGS="-I/usr/local/unimrcp/include -I/usr/local/apr/include/apr-1/"
ENV UNIMRCP_LIBS="/usr/local/unimrcp/lib/libunimrcpclient.a /usr/local/apr/lib/libaprutil-1.a /usr/local/apr/lib/libapr-1.a -lexpat -lsofia-sip-ua -luuid -lcrypt -lpthread -lm"

#RUN ./bootstrap.sh \
#    && ./configure \
#    && make install

RUN . ~/.env \
    && dch \
        --controlmaint \
        --distribution "${CODENAME}" \
        --force-bad-version \
        --force-distribution \
        --newversion "${BUILD_NUMBER}-${GIT_SHA}~${CODENAME}" \
        --package "freeswitch-mod-unimrcp" \
        "Build, ${GIT_SHA}" \
    && debuild \
        --preserve-env \
        --no-tgz-check \
        --build=binary \
        --unsigned-source \
        --unsigned-changes \
    && mkdir OUT \
    && mv -v ../*.{deb,changes} OUT/.

# Artifacts image (mandatory part, the resulting image must have a single filesystem layer)
FROM scratch
COPY --from=builder /data/OUT/ /
