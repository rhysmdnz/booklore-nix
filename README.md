# Nix Booklore
[Booklore](https://github.com/booklore-app/booklore) is a:
> self-hosted web app for organizing and managing your personal book collection. It provides an intuitive interface to browse, read, and track your progress across PDFs and eBooks. With robust metadata management, multi-user support, and a sleek, modern UI, BookLore makes it easy to build and explore your personal library.

[Nix](https://nixos.org/) is a:
> tool that takes a unique approach to package management and system configuration by making builds reproducible, declarative, and reliable.

# The services

This repository hosts the source for two systemd services:
1. The booklore API
2. The booklore Frontend Webapp

that compose the application. These then interact with:

1. A MariaDB database (for the backend api)
2. NGINX (for routing both services through a single port)

# Getting started

Here is the default minimum configuration for the service.

```nix
{
  # Service for creating a mariadb password
  # WARNING: DON'T EXPOSE A STRING PASSWORD IN YOUR ACTUAL CONFIG!!!
  systemd.services.setdbpass = {
        wants = [ "mysql.service" ];
        after = [ "mysql.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = "root";
            ExecStart = ''
                ${pkgs.mariadb}/bin/mysql -u root -e \
                "
                    CREATE USER IF NOT EXISTS 'booklore'@'localhost' IDENTIFIED BY 'passwd';
                    GRANT ALL PRIVILEGES ON booklore.* TO 'booklore'@'localhost';
                    FLUSH PRIVILEGES;
                "
            '';
        };
    };
    services = {
        # MariaDB
        mysql = {
            enable = true;
            package = pkgs.mariadb;
            ensureDatabases = [ "booklore" ];
        };
        # API is a java server on port 8080 by default
        # For full options check the ./nixos/modules/booklore-api.nix file
        booklore-api = {
            enable = true;
            package = self.packages.${pkgs.system}.booklore-api;
            database.host = "127.0.0.1";
            database.password = "passwd";
            wants = [ "mysql.service" "network-online.target" "mysql.service" ];
            after = [ "network-online.target" ];
        };
        # Static web site served on port 6060 by default
        # For full options check ./nixos/modules/booklore-ui.nix file
        booklore-ui = {
            enable = true;
            package = self.packages.${pkgs.system}.booklore-ui;
        };
        # NGINX to serve both sites from the same port. By default 7070
        # This combines our UI to be served at port 7070
        # And our API on port 7070/api
        # And a API websocket on port 7070/ws
        # This helps avoid cors issues and is a hard coded requirement of booklore right now
        nginx = {
            enable = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = true;

            virtualHosts."booklore.local" = {
                listen = [{
                    addr = "0.0.0.0";
                    port = 7070;
                }];

                locations = {
                    "/" = {
                        proxyPass = "http://127.0.0.1:6060";
                        extraConfig = ''
                        proxy_set_header X-Forwarded-Port 7070;
                        proxy_set_header X-Forwarded-Host localhost;
                        '';
                    };

                    "/api" = {
                        proxyPass = "http://127.0.0.1:8080";
                        extraConfig = ''
                        proxy_set_header X-Forwarded-Port 7070;
                        proxy_set_header X-Forwarded-Host localhost;
                        '';
                    };

                    "/ws" = {
                        proxyPass = "http://127.0.0.1:7070/ws";
                        proxyWebsockets = true;
                    };
                };
            };
        };
    };
}
```

**Currently there are some issues with port configuration because of the upstream repository, so currently the configuration requires the ports:**

- 6060
- 7070
- 8080

**It also has some root level folders whos location are hard coded:**

- /books
- /bookdrop

These are all good arguments for just starting a docker compose of the project like they reccomend. But for me I would love to run the application more natively one day, and so this project is condidered to be early development.
