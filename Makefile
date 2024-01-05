.POSIX:

VERSION = 2.1

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
LIBPREFIX = $(PREFIX)/lib
LIBDIR = $(LIBPREFIX)/surf

X11INC = `pkg-config --cflags x11`
X11LIB = `pkg-config --libs x11`

GTKINC = `pkg-config --cflags gtk+-3.0 gcr-3 webkit2gtk-4.0`
GTKLIB = `pkg-config --libs gtk+-3.0 gcr-3 webkit2gtk-4.0`
WEBEXTINC = `pkg-config --cflags webkit2gtk-4.0 webkit2gtk-web-extension-4.0 gio-2.0`
WEBEXTLIBS = `pkg-config --libs webkit2gtk-4.0 webkit2gtk-web-extension-4.0 gio-2.0`

# includes and libs
INCS = $(X11INC) $(GTKINC)
LIBS = $(X11LIB) $(GTKLIB) -lgthread-2.0

# flags
CPPFLAGS = -DVERSION=\"$(VERSION)\" -DGCR_API_SUBJECT_TO_CHANGE \
           -DLIBPREFIX=\"$(LIBPREFIX)\" -DWEBEXTDIR=\"$(LIBDIR)\" \
           -D_DEFAULT_SOURCE
SURFCFLAGS = -fPIC $(INCS) $(CPPFLAGS)
WEBEXTCFLAGS = -fPIC $(WEBEXTINC)

SRC = surf.c
WSRC = webext-surf.c
OBJ = $(SRC:.c=.o)
WOBJ = $(WSRC:.c=.o)
WLIB = $(WSRC:.c=.so)

all: surf $(WLIB)

surf: $(OBJ)
	$(CC) $(SURFLDFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

$(OBJ) $(WOBJ): common.h

$(OBJ): $(SRC)
	$(CC) $(SURFCFLAGS) $(CFLAGS) -c $(SRC)

$(WLIB): $(WOBJ)
	$(CC) -shared -Wl,-soname,$@ $(LDFLAGS) -o $@ $? $(WEBEXTLIBS)

$(WOBJ): $(WSRC)
	$(CC) $(WEBEXTCFLAGS) $(CFLAGS) -c $(WSRC)

clean:
	rm -f surf $(OBJ)
	rm -f $(WLIB) $(WOBJ)

distclean: clean
	rm -f config.h surf-$(VERSION).tar.gz

dist: distclean
	mkdir -p surf-$(VERSION)
	cp -R LICENSE Makefile README.md \
	    surf-open.sh arg.h \
	    common.h $(SRC) $(WSRC) surf-$(VERSION)
	tar -cf surf-$(VERSION).tar surf-$(VERSION)
	gzip surf-$(VERSION).tar
	rm -rf surf-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f surf $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/surf
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp -f $(WLIB) $(DESTDIR)$(LIBDIR)
	for wlib in $(WLIB); do \
	    chmod 644 $(DESTDIR)$(LIBDIR)/$$wlib; \
	done

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/surf
	for wlib in $(WLIB); do \
	    rm -f $(DESTDIR)$(LIBDIR)/$$wlib; \
	done
	- rmdir $(DESTDIR)$(LIBDIR)

.PHONY: all distclean clean dist install uninstall
