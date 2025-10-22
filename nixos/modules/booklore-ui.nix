{
  lib,
  config,
  ...
}:
with lib;
let cfg = config.services.booklore-ui; in {
  options.services.booklore-ui = {
    enable = lib.mkEnableOption "booklore-ui service";

	user = mkOption { type = types.str; default = "booklore"; };
	group = mkOption { type = types.str; default = "booklore"; };

	wants = mkOption {
	  type = types.listOf types.string;
	  description = "Wanted services and targets for triggering start";
	  default = [ "mysql.service" "network-online.target"];
	};

	package = mkOption {
	  type = types.package;
	  description = "Booklore UI static website build with npm wrapper";
	};

	host = mkOption {
	  type = types.str;
	  default = "127.0.0.1";
	  description = "Hostname UI is served from";
	};

    port = mkOption {
      type = types.port;
	  default = 8080;
	  description = "Port UI is served on";
	};

	api-port = mkOption {
      type = types.port;
      default = 6060;
      description = "Port to call API through";
    };

  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
	  isSystemUser = true;
	  group = cfg.group;
	  home = "/var/lib/booklore";
	  createHome = true;
	};
	users.groups.${cfg.group} = { };

	systemd.services.booklore = {
	  description = "Booklore API";
	  wantedBy = [ "multi-user.target" ];
	  after = [ "network-online.target" ];
	  wants = cfg.wants;
	  serviceConfig = {
        User = cfg.user;
		Group = cfg.group;
		ExecStart = "${cfg.package}/bin/booklore-ui";
	  };
	  environment = {
        TZ="Etc/UTC";
        DATABASE_URL=cfg.database.jdbcUrl;	# Only modify this if you're familiar with JDBC and your database setup
        DATABASE_USERNAME=cfg.database.user;							# Must match MYSQL_USER defined in the mariadb container
        DATABASE_PASSWORD=cfg.database.password;				# Use a strong password; must match MYSQL_PASSWORD defined in the mariadb container 
        BOOKLORE_PORT=builtins.toString(cfg.database.port);									# Port BookLore listens on inside the container; must match container port below
        SWAGGER_ENABLED="false";								# Enable or disable Swagger UI (API docs). Set to 'true' to allow access; 'false' to block access (recommended for production).
        FORCE_DISABLE_OIDC="false";								# Set to 'true' to force-disable OIDC and allow internal login, regardless of UI config
	  };
	};
  };
}
