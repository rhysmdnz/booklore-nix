{
  description = "Booklore flake";

  inputs = { };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      version = "v1.17.0";
			hash = "sha256-JPObz0K5gn2utfHWvdIaf0sWq87x2Nrj8AxSNrH9T90=";
      pkgs = import nixpkgs {
        inherit system;
      };
			booklore-api = pkgs.callPackage ./booklore-api.nix { inherit version sha256; };
			booklore-ui = pkgs.callPackage ./booklore-ui.nix { inherit version sha256; };
    in
	{
		formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
		packages.${system} = {
			inherit booklore-api booklore-ui;
		};
		nixosModules.booklore-api = import ./nixos/modules/booklore-api.nix;
		nixosModules.booklore = import ./nixos/modules/booklore.nix;

		nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
			inherit system;
			modules = [
				self.nixosModules.booklore
				./nixos/vm-test.nix
				# Pass modules? Idk how I feel about this
				{
				 services.booklore.ui.package = booklore-ui;
				 services.booklore-api.package = booklore-api;
				}
				# Config for VM allocation
				(
					{ config, pkgs, ... }:
					{
						virtualisation.vmVariant = {
							virtualisation = {
								memorySize = 4096;
								cores = 2;
							};
						};
					}
				)
			];
		};
	};
}
