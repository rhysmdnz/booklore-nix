{
  description = "Booklore flake";

  inputs = {
    build-gradle-application.url = "github:raphiz/buildGradleApplication";
  };

  outputs = { self, nixpkgs, build-gradle-application, ... }:
    let
      system = "x86_64-linux";
	  pkgs = import nixpkgs {
			inherit system;
			overlays = [build-gradle-application.overlays.default];
    };
    in {
			packages.${system} = {
				booklore-api = pkgs.callPackage ./booklore-api.nix { };
				booklore-ui = pkgs.callPackage ./booklore-ui.nix { };
			};
			nixosModules.booklore-api = import ./nixos/modules/booklore-api.nix;
			nixosModules.booklore-ui = import ./nixos/modules/booklore-ui.nix;

			nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
				inherit system;
				modules = [
					self.nixosModules.booklore-api
					self.nixosModules.booklore-ui
					(import ./nixos/vm-test.nix { inherit self pkgs;})
					# Config for VM size
					({config, pkgs, ...}: {
					  virtualisation.vmVariant = {
							virtualisation = {
								memorySize	= 4096;  # in MiB
								cores				= 2;
							};
						};
					})
				];
			};
  };
}
