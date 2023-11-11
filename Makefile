# surf - simple browser
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = surf.c
WSRC = webext-surf.c
OBJ = $(SRC:.c=.o)
WOBJ = $(WSRC:.c=.o)
WLIB = $(WSRC:.c=.so)

all: options surf $(WLIB)

options:
	@echo surf build options:
	@echo "CC            = $(CC)"
	@echo "CFLAGS        = $(SURFCFLAGS) $(CFLAGS)"
	@echo "WEBEXTCFLAGS  = $(WEBEXTCFLAGS) $(CFLAGS)"
	@echo "LDFLAGS       = $(LDFLAGS)"

surf: $(OBJ)
	$(CC) $(SURFLDFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

$(OBJ) $(WOBJ): config.h common.h config.mk

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
	cp -R LICENSE Makefile config.mk README.md \
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

.PHONY: all options distclean clean dist install uninstall
