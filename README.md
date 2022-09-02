# MRCP Module For FreeSWITCH

## How to build

1. Build FreeSWITCH and its dependencies
```
$ sudo apt-get update 
$ sudo apt-get install git
$ git clone https://github.com/signalwire/freeswitch
$ git clone https://github.com/signalwire/libks
$ git clone https://github.com/freeswitch/sofia-sip
$ git clone https://github.com/freeswitch/spandsp
$ git clone https://github.com/signalwire/signalwire-c
$ sudo apt-get install \
    build-essential cmake automake autoconf 'libtool-bin|libtool' pkg-config \
    libssl-dev zlib1g-dev libdb-dev unixodbc-dev libncurses5-dev libexpat1-dev libgdbm-dev bison erlang-dev libtpl-dev libtiff5-dev uuid-dev \
    libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev nasm \
    libogg-dev libspeex-dev libspeexdsp-dev \
    libldns-dev \
    python3-dev \
    libavformat-dev libswscale-dev libavresample-dev \
    liblua5.2-dev \
    libopus-dev \
    libpq-dev \
    libsndfile1-dev libflac-dev libogg-dev libvorbis-dev

$ cd libks
$ cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1
$ sudo make install
$ cd ..

$ cd sofia-sip
$ ./bootstrap.sh
$ ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr
$ make -j`nproc --all`
$ sudo make install
$ cd ..

$ cd spandsp
$ ./bootstrap.sh
$ ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr
$ make -j`nproc --all`
$ sudo make install
$ cd ..

$ cd signalwire-c
$ PKG_CONFIG_PATH=/usr/lib/pkgconfig cmake . -DCMAKE_INSTALL_PREFIX=/usr
$ sudo make install
$ cd ..

$ cd freeswitch
$ ./bootstrap.sh -j
$ ./configure
$ make -j`nproc`
$ sudo make install
$ cd ..
```

2. Build UniMRCP dependencies (APR, APR-Utils)
```
$ sudo apt-get install wget tar
$ wget https://www.unimrcp.org/project/component-view/unimrcp-deps-1-6-0-tar-gz/download -O unimrcp-deps-1.6.0.tar.gz
$ tar xvzf unimrcp-deps-1.6.0.tar.gz
$ cd unimrcp-deps-1.6.0

$ cd libs/apr
$ ./configure --prefix=/usr/local/apr
$ make
$ sudo make install 
$ cd ..

$ cd apr-util
$ ./configure --prefix=/usr/local/apr
$ make
$ sudo make install
$ cd ..

$ git clone https://github.com/unispeech/unimrcp.git
$ cd unimrcp
$ ./bootstrap
$ ./configure
$ make
$ sudo make install
$ cd ..

```

3. Build mod_unimrcp and install
```
$ git clone https://github.com/freeswitch/mod_unimrcp.git
$ cd mod_unimrcp
$ export PKG_CONFIG_PATH=/usr/local/freeswitch/libs/pkgconfig:/usr/local/unimrcp/libs/pkgconfig
$ ./bootstrap.sh
$ ./configure
$ make
$ sudo make install
$ cd ..
```

## Docs

https://freeswitch.org/confluence/display/FREESWITCH/mod_unimrcp
