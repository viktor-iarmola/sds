LIB_CFLAGS	:= -Wall -Wextra -pedantic -fPIC

# The main and minor version of the library
# The library soname (major number) must be changed if and only if the
# interface is changed in a backward incompatible way.  The interface is
# defined by the public header files - in this case they are only smbus.h.
LIB_MAINVER	 := 0
LIB_MINORVER := 1.0
LIB_VER		 := $(LIB_MAINVER).$(LIB_MINORVER)

# The shared and static library names
LIB_SHBASENAME	:= libsds.so
LIB_SHSONAME	:= $(LIB_SHBASENAME).$(LIB_MAINVER)
LIB_SHLIBNAME	:= $(LIB_SHBASENAME).$(LIB_VER)

LIB_LINKS	:= $(LIB_SHSONAME) $(LIB_SHBASENAME)
LIB_TARGETS	+= $(LIB_SHLIBNAME)

LIB_DEPS	:= $(LIB_DIR)/$(LIB_SHBASENAME)

.PHONY: all install uninstall install-lib uninstall-lib

all: $(LIB_TARGETS)

install: install-lib
uninstall: uninstall-lib

sdstest: sdstest.o sds.h
	$(CC) -o $@ $< -lsds

sds.o: sds.c sds.h
	$(CC) $(SOCFLAGS) $(LIB_CFLAGS) -c $< -o $@

$(LIB_SHLIBNAME): sds.o
	$(CC) -shared $(LDFLAGS) -Wl,--version-script=libsds.map -Wl,-soname,$(LIB_SHSONAME) -o $@ $^

INSTALL := install
LN := ln -sf
RM := rm

DESTDIR=/usr/local
libdir := lib
incdir := include

# install-lib: $(LIB_TARGETS)
# 	echo $(INSTALL_DIR) $(DESTDIR)$(libdir)
# 	echo $(INSTALL_PROGRAM) $(LIB_DIR)/$(LIB_SHLIBNAME) $(DESTDIR)$(libdir)
# 	$(INSTALL_DIR) $(DESTDIR)$(libdir)
# 	$(INSTALL_PROGRAM) $(LIB_DIR)/$(LIB_SHLIBNAME) $(DESTDIR)$(libdir)
# 	$(LN) $(LIB_SHLIBNAME) $(DESTDIR)$(libdir)/$(LIB_SHSONAME)
# 	$(LN) $(LIB_SHSONAME) $(DESTDIR)$(libdir)/$(LIB_SHBASENAME)

install-header: sds.h
	$(INSTALL) $< $(DESTDIR)/$(incdir) 

uninstall-header:
	$(RM) $(DESTDIR)/$(incdir)/sds.h

install-lib: $(LIB_TARGETS)
	$(INSTALL) $(LIB_SHLIBNAME) $(DESTDIR)
	$(LN) $(LIB_SHLIBNAME) $(DESTDIR)/$(libdir)/$(LIB_SHSONAME)
	$(LN) $(LIB_SHSONAME) $(DESTDIR)/$(libdir)$(LIB_SHBASENAME)

uninstall-lib:
	$(RM) $(DESTDIR)/$(LIB_SHLIBNAME)
	$(RM) $(DESTDIR)/$(LIB_SHSONAME)
	$(RM) $(DESTDIR)/$(LIB_SHBASENAME)

clean:
	$(RM) -f $(LIB_TARGETS) *.o
