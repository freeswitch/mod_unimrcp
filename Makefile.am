-include $(top_srcdir)/build/modmake.rulesam
AUTOMAKE_OPTIONS = foreign subdir-objects
MODNAME=mod_unimrcp

LIBS := $(if $(switch_builddir),$(switch_builddir)/libfreeswitch.la,)

if HAVE_UNIMRCP

mod_LTLIBRARIES = mod_unimrcp.la
mod_unimrcp_la_SOURCES  = mod_unimrcp.c
mod_unimrcp_la_CFLAGS   = $(AM_CFLAGS) $(FREESWITCH_CFLAGS) $(UNIMRCP_CFLAGS)
mod_unimrcp_la_LDFLAGS  = -avoid-version -module -no-undefined -shared $(FREESWITCH_LIBS) $(UNIMRCP_LIBS)
mod_unimrcp_la_LIBADD   = $(LIBS)

else
install: error
all: error
error:
    $(error You must install libunimrcp and libunimrcp-dev to build this module)
endif
