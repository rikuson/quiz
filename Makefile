PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

PLATFORMFILE := src/platform/$(shell uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]').sh

BASHCOMPDIR ?= $(PREFIX)/share/bash-completion/completions
ZSHCOMPDIR ?= $(PREFIX)/share/zsh/site-functions
FISHCOMPDIR ?= $(PREFIX)/share/fish/vendor_completions.d

ifneq ($(WITH_ALLCOMP),)
WITH_BASHCOMP := $(WITH_ALLCOMP)
WITH_ZSHCOMP := $(WITH_ALLCOMP)
WITH_FISHCOMP := $(WITH_ALLCOMP)
endif
ifeq ($(WITH_BASHCOMP),)
ifneq ($(strip $(wildcard $(BASHCOMPDIR))),)
WITH_BASHCOMP := yes
endif
endif
ifeq ($(WITH_ZSHCOMP),)
ifneq ($(strip $(wildcard $(ZSHCOMPDIR))),)
WITH_ZSHCOMP := yes
endif
endif
ifeq ($(WITH_FISHCOMP),)
ifneq ($(strip $(wildcard $(FISHCOMPDIR))),)
WITH_FISHCOMP := yes
endif
endif

all:
	@echo "Quiz store is a shell script, so there is nothing to do. Try \"make install\" instead."

install-common:
	@install -v -d "$(DESTDIR)$(MANDIR)/man1" && install -m 0644 -v man/quiz.1 "$(DESTDIR)$(MANDIR)/man1/quiz.1"
	@[ "$(WITH_BASHCOMP)" = "yes" ] || exit 0; install -v -d "$(DESTDIR)$(BASHCOMPDIR)" && install -m 0644 -v src/completion/quiz.bash-completion "$(DESTDIR)$(BASHCOMPDIR)/quiz"
	@[ "$(WITH_ZSHCOMP)" = "yes" ] || exit 0; install -v -d "$(DESTDIR)$(ZSHCOMPDIR)" && install -m 0644 -v src/completion/quiz.zsh-completion "$(DESTDIR)$(ZSHCOMPDIR)/_quiz"
	@[ "$(WITH_FISHCOMP)" = "yes" ] || exit 0; install -v -d "$(DESTDIR)$(FISHCOMPDIR)" && install -m 0644 -v src/completion/quiz.fish-completion "$(DESTDIR)$(FISHCOMPDIR)/quiz.fish"


ifneq ($(strip $(wildcard $(PLATFORMFILE))),)
install: install-common
	@install -v -d "$(DESTDIR)$(LIBDIR)/quiz-store" && install -m 0644 -v "$(PLATFORMFILE)" "$(DESTDIR)$(LIBDIR)/quiz-store/platform.sh"
	@install -v -d "$(DESTDIR)$(LIBDIR)/quiz-store/extensions"
	@install -v -d "$(DESTDIR)$(BINDIR)/"
	@trap 'rm -f src/.quiz' EXIT; sed 's:.*PLATFORM_FUNCTION_FILE.*:source "$(LIBDIR)/quiz-store/platform.sh":;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="$(LIBDIR)/quiz-store/extensions":' src/quiz-store.sh > src/.quiz && \
	install -v -d "$(DESTDIR)$(BINDIR)/" && install -m 0755 -v src/.quiz "$(DESTDIR)$(BINDIR)/quiz"
else
install: install-common
	@install -v -d "$(DESTDIR)$(LIBDIR)/quiz-store/extensions"
	@trap 'rm -f src/.quiz' EXIT; sed '/PLATFORM_FUNCTION_FILE/d;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="$(LIBDIR)/quiz-store/extensions":' src/quiz-store.sh > src/.quiz && \
	install -v -d "$(DESTDIR)$(BINDIR)/" && install -m 0755 -v src/.quiz "$(DESTDIR)$(BINDIR)/quiz"
endif

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(BINDIR)/quiz" \
		"$(DESTDIR)$(LIBDIR)/quiz-store" \
		"$(DESTDIR)$(MANDIR)/man1/quiz.1" \
		"$(DESTDIR)$(BASHCOMPDIR)/quiz" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_quiz" \
		"$(DESTDIR)$(FISHCOMPDIR)/quiz.fish"

TESTS = $(sort $(wildcard tests/t[0-9][0-9][0-9][0-9]-*.sh))

test: $(TESTS)

$(TESTS):
	@$@ $(PASS_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/ tests/gnupg/random_seed

.PHONY: install uninstall install-common test clean $(TESTS)
