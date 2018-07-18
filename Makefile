PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
LIBDIR ?= $(DESTDIR)$(PREFIX)/lib/egpg
MANDIR ?= $(DESTDIR)$(PREFIX)/share/man/man1
BASHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/bash-completion/completions

all: install

install: uninstall
	@install -v -d "$(BINDIR)/"
	@install -v -m 0755 src/egpg.sh "$(BINDIR)/egpg"
	@sed -i $(BINDIR)/egpg -e "s#^LIBDIR=.*#LIBDIR=\"$(PREFIX)/lib/egpg\"#"

	@install -v -d "$(LIBDIR)/"
	@cp -v -r src/* "$(LIBDIR)/"

	@install -v -d "$(BASHCOMP_PATH)"
	@mv -v "$(LIBDIR)"/bash-completion.sh "$(BASHCOMP_PATH)"/egpg
	@chmod -c 0644 "$(BASHCOMP_PATH)"/egpg

	@install -v -d "$(MANDIR)/"
	@install -v -m 0644 man/egpg.1 "$(MANDIR)/egpg.1"

uninstall:
	@rm -vrf "$(BINDIR)/egpg" "$(LIBDIR)" "$(MANDIR)/egpg.1" "$(BASHCOMP_PATH)"/egpg

TESTS = $(sort $(wildcard tests/t*.t))

test: $(TESTS)

deb:
	./deb.sh

$(TESTS):
	@$@ $(EGPG_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/ tests/gnupg/random_seed

.PHONY: install uninstall test clean $(TESTS)
