{ pkgs, booklore-api, booklore-ui, ... }:

{
  networking.hostName = "booklore-vm";
  systemd.services.setdbpass = {
    wants = [ "mysql.service" ];
    after = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
		script = ''
			${pkgs.mariadb}/bin/mysql -u root -e \
			"
				CREATE DATABASE IF NOT EXISTS booklore;
				DROP USER IF EXISTS 'booklore'@'localhost';
				DROP USER IF EXISTS 'booklore'@'%';
				CREATE USER 'booklore'@'localhost' IDENTIFIED BY 'passwd';
				GRANT ALL PRIVILEGES ON booklore.* TO 'booklore'@'localhost';
				FLUSH PRIVILEGES;
			"
		'';
  };

  services = {
    getty.autologinUser = "root";
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    booklore-api = {
      enable = true;
      package = booklore-api;
      database.host = "127.0.0.1";
      database.password = "passwd";
    };

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

			virtualHosts."booklore.local" = {
				root = "${booklore-ui}/lib/node_modules/booklore/dist/booklore/browser/";
				# index = "index.html";
        listen = [
          { port = 7070; addr = "0.0.0.0"; }
        ];
				locations = {
					"/" = {
						tryFiles="$uri $uri/ /index.html";
						extraConfig = ''
							location ~* \.mjs$ {
									# target only *.mjs files
									# now we can safely override types since we are only
									# targeting a single file extension.
									types {
											text/javascript mjs;
									}
							}
						'';
					};
          "/api/" = {
            proxyPass = "http://127.0.0.1:8080";
            extraConfig = ''
              						proxy_set_header X-Forwarded-Port 7070;
              						proxy_set_header X-Forwarded-Host localhost;
              					'';
          };
          "/ws" = {
            proxyPass = "http://127.0.0.1:8080/ws";
            proxyWebsockets = true;
          };
				};
			};
    };
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  users.users.carter = {
    isNormalUser = true;
    enable = true;
    password = "Test";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

}
