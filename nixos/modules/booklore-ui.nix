{
  lib,
  config,
  ...
}:
let
  cfg = config.services.booklore-ui;
in
{
  options.services.booklore-ui = {
    enable = lib.mkEnableOption "booklore-ui service";

    user = lib.mkOption {
      type = lib.types.str;
      default = "booklore-ui";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "booklore-ui";
    };

    wants = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Wanted services and targets for triggering start";
      default = [
        "mysql.service"
        "network-online.target"
      ];
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "Booklore UI static website build with npm wrapper";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Hostname UI is served from";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6060;
      description = "Port UI is served on";
    };

    api-port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to call API through, for now don't change this because it's hard coded in booklore (reference their enviroment.ts file)";
    };

  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = "/var/lib/booklore";
      createHome = true;
    };
    users.groups.${cfg.group} = { };

    systemd.services.booklore-ui = {
      description = "Booklore API";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      inherit (cfg) wants;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/booklore-ui";
      };
      environment = {
        TZ = "Etc/UTC";
        BOOKLORE_PORT = builtins.toString cfg.api-port;
        SWAGGER_ENABLED = "false";
        FORCE_DISABLE_OIDC = "false";
        PORT = builtins.toString cfg.port;
        HOST = cfg.host;
      };
    };
  };
}
