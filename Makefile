# Tools are pinned in mise.toml. `make deps` installs mise if it's missing
# (with Homebrew), then the tools mise.toml lists.

.PHONY: deps install doctor check

deps:
	@command -v mise >/dev/null || brew install mise
	mise trust --quiet mise.toml
	mise install

install: deps
	mise exec -- scripts/install

doctor:
	mise exec -- scripts/doctor

check:
	scripts/validate-skills
	scripts/validate-agents
