# `make` installs this repo's skills, agents, and config (scripts/install).
# It needs only jq, installed with Homebrew if it's missing.
# `make deps` installs the optional tools statechart needs, pinned in mise.toml.

.PHONY: install dry-run update deps doctor check

install:
	@command -v jq >/dev/null || brew install jq
	scripts/install

dry-run:
	scripts/install --dry-run

update:
	git pull --ff-only
	$(MAKE) install

MISE := $(or $(shell command -v mise),$(wildcard $(HOME)/.local/bin/mise))

deps:
	@[ -n "$(MISE)" ] || { echo "error: mise not on PATH or in ~/.local/bin (it comes from dotfiles)" >&2; exit 1; }
	$(MISE) trust --quiet mise.toml
	$(MISE) install

doctor:
	scripts/doctor

check:
	scripts/validate-skills
	scripts/validate-agents
