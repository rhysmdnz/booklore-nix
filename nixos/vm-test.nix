{self, pkgs, ...}:

{
  networking.hostName = "booklore-vm";
  services.getty.autologinUser = "root";

  services.mysql = {
    enable = true;
	package = pkgs.mariadb;
	ensureDatabases = [ "booklore" ];
  };

  systemd.services.setdbpass = {
    wants = [ "mysql.service" ];
	wantedBy = [ "multi-user.target" ];
	serviceConfig = {
	  Type = "oneshot";
	  RemainAfterExit = true;
	  User = "root";
	  ExecStart = ''
        ${pkgs.mariadb}/bin/mysql -u root -e \
		"CREATE booklore@localhost IF NOT EXISTS IDENTIFIED BY 'passwd';"
	  '';
	};
  };

  services.booklore-api = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-api;
	database.host = "localhost";
	database.password = "passwd";
	port = 7070;
  };

  services.booklore-ui = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-ui;
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  services = {
	displayManager.sddm.enable = true;
	displayManager.sddm.wayland.enable = true;
  };

  users.users.carter = {
    isNormalUser = true;
	enable = true;
	password = "Test";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
