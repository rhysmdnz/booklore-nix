{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  nodejs,
  nodePackages,
  stdenv,
  version,
}:

buildNpmPackage (_finalAttrs: {
  pname = "booklore-ui";
  inherit version;
  src = fetchFromGitHub {
    owner = "booklore-app";
    repo = "booklore";
    rev = version;
    sha256 = "0c369fl6wds75kync2kgjm1z1777rbbnlsk9z606lgicqv4akw4v";
  };

  sourceRoot = "${_finalAttrs.src.name}/booklore-ui";

  npmDepsHash = "sha256-ETzFwSNF+qLuiKdnkwsd9LUqEtNf5fJpgmO4+rfnWr8=";

  npmPackFlags = [ "--ignore-scripts" ];

  NODE_OPTIONS = "--openssl-legacy-provider";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    nodejs
    nodePackages.http-server
  ];

  installPhase = ''
    	  runHook preInstall

    	  mkdir -p $out/bin
    	  mkdir -p $out/share
    	  mkdir -p $out/share/booklore-ui
          cp -r dist/booklore/browser/* $out/share/booklore-ui/
    	  makeWrapper ${nodePackages.http-server}/bin/http-server \
    	  $out/bin/booklore-ui \
    	  --add-flags "$out/share/booklore-ui" \
    	  --add-flags "-p 6060"

    	  runHook postInstall
    	'';

  meta = {
    description = "Web UI for Booklore";
    homepage = "https://github.com/booklore-app/booklore/tree/develop";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ carter ];
  };
})
