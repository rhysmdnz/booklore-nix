{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}: let
  version = "v1.6.0";

  _src = fetchFromGitHub {
    owner = "booklore-app";
    repo = "booklore";
    rev = "v1.6.0";
    sha256 = "0c369fl6wds75kync2kgjm1z1777rbbnlsk9z606lgicqv4akw4v";
  };

  self = buildNpmPackage (_finalAttrs:{
    pname = "booklore-ui";
    inherit version;

	src = _src;

    npmDepsHash = "sha256-8m+6H1zvwci+SXWh1TkbBl1ljUtkYPWD5TPEj8LCJ1M=";
    
	npmPackFlags = [ "--ignore-scripts" ];

  
    NODE_OPTIONS = "--openssl-legacy-provider";
  
    meta = {
      description = "Modern web UI for various torrent clients with a Node.js backend and React frontend";
      homepage = "https://flood.js.org";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ winter ];
    };
  });
in
  self
