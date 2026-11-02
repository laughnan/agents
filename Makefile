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

deps:
	@command -v mise >/dev/null || { echo "error: mise is required (install it with your dotfiles)" >&2; exit 1; }
	mise trust --quiet mise.toml
	mise install

doctor:
	scripts/doctor

check:
	scripts/validate-skills
	scripts/validate-agents
