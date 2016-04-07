PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
LIBDIR ?= $(DESTDIR)$(PREFIX)/lib
MANDIR ?= $(DESTDIR)$(PREFIX)/share/man/man1
BASHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/bash-completion/completions

EGPG = $(BINDIR)/egpg
LIB = $(LIBDIR)/egpg

all: install

install: uninstall
	@install -v -d "$(LIB)/"
	@cp -v -r src/* "$(LIB)"

	@install -v -d "$(BINDIR)/"
	@mv -v "$(LIB)"/egpg.sh "$(EGPG)"
	@sed -i "$(EGPG)" -e "s#LIBDIR=.*#LIBDIR=\"$(LIB)\"#"
	@chmod -c 0755 "$(EGPG)"

	@install -v -d "$(BASHCOMP_PATH)"
	@mv -v "$(LIB)"/bash-completion.sh "$(BASHCOMP_PATH)"/egpg
	@chmod -c 0644 "$(BASHCOMP_PATH)"/egpg

	@install -v -d "$(MANDIR)/"
	@install -v -m 0644 man/egpg.1 "$(MANDIR)/egpg.1"

uninstall:
	@rm -vrf "$(EGPG)" "$(LIB)" "$(MANDIR)/egpg.1" "$(BASHCOMP_PATH)"/egpg

TESTS = $(sort $(wildcard tests/t*.t))

test: $(TESTS)

$(TESTS):
	@$@ $(EGPG_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/ tests/gnupg/random_seed

.PHONY: install uninstall test clean $(TESTS)
