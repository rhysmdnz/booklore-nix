{self, pkgs, ...}:

{
  networking.hostName = "booklore-vm";
  services.getty.autologinUser = "root";

  services.mysql = {
    enable = true;
	package = pkgs.mariadb;
	ensureDatabases = [ "booklore" ];
	ensureUsers = [
	  {
	    name = "booklore";
		ensurePermissions = {
          "booklore.*" = "ALL PRIVILEGES";
		};
	  }
	];
  };

  services.booklore-api = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-api;
  };
}
