PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
LIBDIR ?= $(DESTDIR)$(PREFIX)/lib
MANDIR ?= $(DESTDIR)$(PREFIX)/share/man/man1

EGPG = $(BINDIR)/egpg
LIB = $(LIBDIR)/egpg

all: install

install:
	@install -v -d "$(BINDIR)/"
	@install -v -m 0755 src/egpg.sh "$(EGPG)"
	@sed -i $(EGPG) -e "s#LIBDIR=.*#LIBDIR=\"$(LIB)\"#"

	@install -v -d "$(LIB)/"
	@cp -v -r src/platform src/ext "$(LIB)"

	@install -v -d "$(MANDIR)/"
	@install -v -m 0644 man/egpg.1 "$(MANDIR)/egpg.1"

uninstall:
	@rm -vrf "$(EGPG)" "$(LIB)" "$(MANDIR)/egpg.1"

TESTS = $(sort $(wildcard tests/t*.t))

test: $(TESTS)

$(TESTS):
	@$@ $(EGPG_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/ tests/gnupg/random_seed

.PHONY: install uninstall test clean $(TESTS)
