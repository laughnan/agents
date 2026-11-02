# `make` installs everything: the tools pinned in mise.toml, then this repo's
# skills, agents, and config (scripts/install). `make update` pulls first.

.PHONY: install deps dry-run update doctor check

install: deps
	mise exec -- scripts/install

deps:
	@command -v mise >/dev/null || brew install mise
	mise trust --quiet mise.toml
	mise install

dry-run: deps
	mise exec -- scripts/install --dry-run

update:
	git pull --ff-only
	$(MAKE) install

doctor:
	mise exec -- scripts/doctor

check:
	scripts/validate-skills
	scripts/validate-agents
