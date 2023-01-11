{
  description = "Shipnix server configuration for ihp-npm-shipnix";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nix-npm-buildpackage = { url = "github:serokell/nix-npm-buildpackage"; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-npm-buildpackage } @attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        # use this variant if unfree packages are needed:
        # unstable = import nixpkgs-unstable {
        #  inherit system;
        #  config.allowUnfree = true;
        # };
      };
      nixPackages = nixpkgs.legacyPackages.${system};
      buildPackage = nixPackages.callPackage nix-npm-buildpackage { };
      elmOutput = nixPackages.callPackage ./elm/elm.nix { };
      nodeDependencies = buildPackage.mkNodeModules {
        src = ./.;
        pname = "npm";
        version = "8";
        buildInputs = [ nixPackages.python3 ];
      };
      # This is a derivation that lets you build your frontend in production
      frontendAssets = nixPackages.stdenv.mkDerivation
        (
          {
            name = "frontend-assets";
            buildInputs = [ nixPackages.esbuild nixPackages.elmPackages.elm ];
            src = ./elm/.;
            installPhase = ''
              export NODE_ENV=production
              export NODE_PATH=${nodeDependencies}/node_modules
              export OUT_DIR=$out
              export NODE_ENV=production
              cp -r $src .
              export npm_config_cache=${nodeDependencies}/config-cache
              cp ${elmOutput}/Main.js .
              mkdir -p $out/frontend-assets
              esbuild index.js --bundle --outfile=$out/frontend-assets/app.js --minify
            '';
          }
        );
    in
    {
      nixosConfigurations."ihp-npm-shipnix" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs // {
          environment = "production";
          frontendAssets = frontendAssets;
        };
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./nixos/configuration.nix
        ];
      };
    };
}
    