NIX_BUILD ?= nix build --no-out-link

all:
	$(NIX_BUILD)
