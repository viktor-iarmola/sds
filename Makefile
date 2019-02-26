.PHONY: all install uninstall install-lib uninstall-lib

LIB_MAINVER	 := 0
LIB_MINORVER := 1.0
LIB_VER		 := $(LIB_MAINVER).$(LIB_MINORVER)

LIB_SHBASENAME	:= libsds.so
LIB_SHSONAME	:= $(LIB_SHBASENAME).$(LIB_MAINVER)
LIB_SHLIBNAME	:= $(LIB_SHBASENAME).$(LIB_VER)

LIB_LINKS	:= $(LIB_SHSONAME) $(LIB_SHBASENAME)
LIB_TARGETS	+= $(LIB_SHLIBNAME)

LIB_DEPS	:= $(LIB_DIR)/$(LIB_SHBASENAME)

DESTDIR	=
prefix	?= /usr/local
incdir	= $(prefix)/include
libdir	= $(prefix)/lib

INSTALL		:= install
INSTALL_DATA	:= $(INSTALL) -m 644
INSTALL_DIR	:= $(INSTALL) -m 755 -d
INSTALL_PROGRAM	:= $(INSTALL) -m 755
LN		:= ln -sf
RM		:= rm -f

CFLAGS		+= -Wall -Wextra
SOCFLAGS	:= -fPIC -D_REENTRANT $(CFLAGS)

all: $(LIB_TARGETS)

install: install-lib
uninstall: uninstall-lib

sdstest: sdstest.o sds.h
	$(CC) -o $@ $(CFLAGS) $< -lsds

sds.o: sds.c sds.h
	$(CC) $(SOCFLAGS) -c $< -o $@

$(LIB_SHLIBNAME): sds.o
	$(CC) -shared $(LDFLAGS) -Wl,--version-script=libsds.map -Wl,-soname,$(LIB_SHSONAME) -o $@ $^

install-header: sds.h
	$(INSTALL_DIR) $(DESTDIR)$(incdir)
	$(INSTALL_DATA) $< $(DESTDIR)$(incdir)

uninstall-header:
	$(RM) $(DESTDIR)$(incdir)/sds.h

install-lib: $(LIB_TARGETS)
	$(INSTALL_DIR) $(DESTDIR)$(libdir)
	$(INSTALL_PROGRAM) $(LIB_SHLIBNAME) $(DESTDIR)$(libdir)
	$(LN) $(LIB_SHLIBNAME) $(DESTDIR)$(libdir)/$(LIB_SHSONAME)
	$(LN) $(LIB_SHSONAME) $(DESTDIR)$(libdir)/$(LIB_SHBASENAME)

uninstall-lib:
	$(RM) $(DESTDIR)$(libdir)/$(LIB_SHLIBNAME)
	$(RM) $(DESTDIR)$(libdir)/$(LIB_SHSONAME)
	$(RM) $(DESTDIR)$(libdir)/$(LIB_SHBASENAME)

clean:
	$(RM) -f $(LIB_TARGETS) *.o
