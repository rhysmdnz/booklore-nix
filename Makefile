default:
	make deps.json
	make result
ui:
	nix build .#booklore-ui
api:
	nix build .#booklore-api
deps.json:
	nix build .#booklore-api.mitmCache.updateScript
	./result
vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
lint:
	nix run nixpkgs#statix -- check
