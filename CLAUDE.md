# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`quiz` is a Bash CLI for managing flashcard-style quizzes, forked from [pass](https://www.passwordstore.org). Each quiz lives as a `.yml` file under a store directory (default `~/.quiz-store`, overridable via `QUIZ_STORE_DIR`). The store can optionally be a git repo, in which case mutating commands automatically commit.

## Common commands

- `make install` — installs `quiz` to `$PREFIX/bin` (default `/usr`), the platform shim to `$PREFIX/lib/quiz-store/platform.sh`, the man page, and shell completions. On macOS use `PREFIX=$(brew --prefix) make install`.
- `make test` — runs the full Sharness suite (every `tests/t[0-9][0-9][0-9][0-9]-*.sh`).
- `tests/tNNNN-*.sh -v` — run a single test with verbose output (per `INSTALL`). Pass extra Sharness flags via `QUIZ_TEST_OPTS=...`.
- `npx editorconfig-checker` — the only lint step CI runs (see `.github/workflows/main.yml`).
- `make uninstall` / `make clean` — remove install artifacts / clear `tests/test-results` and trash dirs.

There is no build step — `all` just prints a notice. CI runs `sudo make install && make test` on Ubuntu and `brew install tree gnu-sed && make test` on macOS.

## Architecture

**Single-script dispatcher.** All logic lives in `src/quiz-store.sh`. The bottom `case` block (~line 403) maps subcommands (`init`, `show|ls|list`, `find|search`, `grep`, `insert|add`, `edit`, `delete|rm|remove`, `rename|mv`, `copy|cp`, `git`) to `cmd_*` functions. Unknown subcommands fall through to `cmd_extension_or_show`, which tries to load an extension and otherwise treats the argument as a quiz path to show.

**Platform shim.** `src/platform/{darwin,freebsd,openbsd}.sh` is sourced near the top of `quiz-store.sh` (the `PLATFORM_FUNCTION_FILE` marker line). Each shim overrides `tmpdir` and the `GETOPT` / `SHRED` / `BASE64` / `SED` variables. On macOS this means `gsed` and Homebrew `gnu-getopt` are required at runtime — tests likewise source the shim from `tests/setup.sh`. The `Makefile`'s `install` target rewrites `PLATFORM_FUNCTION_FILE` and `SYSTEM_EXTENSION_DIR` lines via `sed` while installing.

**Git integration is woven into the commands, not a separate layer.** `set_git` walks up from a target file looking for the inner `.git` dir; `git_add_file` / `git_commit` are no-ops when no repo is found. Mutating commands (`cmd_insert`, `cmd_edit`, `cmd_delete`, `cmd_copy_move`) call these so a single `quiz add` produces a commit if the store is a git repo. `cmd_git` proxies arbitrary git commands through `git -C "$INNER_GIT_DIR"`.

**Quiz file format is YAML-ish but written as plain text.** `cmd_insert` (without `-m`) writes literal `question: ...\nanswer: ...` to a `.yml` file; `cmd_show` just `cat`s it. Recent commit `65b0d5f` switched the on-disk format to YAML — keep new quiz-file logic consistent with that, not the older single-line answer format still visible in the README.

**Extensions** are bash files under `$QUIZ_STORE_EXTENSIONS_DIR/<name>.bash` (gated by `QUIZ_STORE_ENABLE_EXTENSIONS=true`) or `$SYSTEM_EXTENSION_DIR/<name>.bash`. They're sourced in the running shell, so they share all functions/variables defined in `quiz-store.sh`.

**Path safety.** `check_sneaky_paths` rejects any argument containing `..` segments — every command that accepts a quiz name calls it before touching the filesystem. Preserve this when adding new subcommands.

## Tests

Sharness-based, files named `tNNNN-description.sh`. `tests/setup.sh` is sourced by every test: it unsets all `QUIZ_*` env vars, points `QUIZ_STORE_DIR` at `$SHARNESS_TRASH_DIRECTORY/test-store/`, configures a throwaway git identity, and re-sources the platform shim so `$SED` etc. are available inside tests. `tests/fake-answer.sh` and `tests/fake-editor-change-answer.sh` are stub editors used to script interactive prompts.

When adding a test, copy an existing `tNNNN-*.sh`, increment the number to fit the topic group (`0001` sanity, `0020` show, `0050` mv, `0060` rm, `0100` add, `0200` edit, `0400` grep, `0500` find), and invoke `"$QUIZ"` (the absolute path set in `setup.sh`) rather than `quiz`.

## Style

`.editorconfig` enforces tabs, LF, UTF-8, final newline, and trimmed trailing whitespace for `*.sh`. `editorconfig-checker` is the CI gate, so non-tab indentation will fail lint.
