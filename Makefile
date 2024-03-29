NIX_BUILD ?= nix build --no-link

BOX_NAME ?= datakurre/automation-playground
BOX_VERSION ?= 0.5.0

all:
	$(NIX_BUILD)

.PHONY: publish
publish:
	vagrant cloud publish -rf $(BOX_NAME) $(BOX_VERSION) virtualbox $$($(NIX_BUILD) --json .#vagrantbox|jq -r .[0].outputs.out)
