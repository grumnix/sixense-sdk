{
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    hydrajoy_src.url = "github:yomboprime/hydrajoy";
    hydrajoy_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, hydrajoy_src }:
    flake-utils.lib.eachSystem [ "i686-linux" "x86_64-linux" ]  (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = sixense-sdk;

          sixense-sdk = pkgs.stdenv.mkDerivation rec {
            pname = "sixense-sdk";
            version = "0.0";

            src = hydrajoy_src;

            buildPhase = ''
              # do nothing
            '';

            installPhase = ''
              mkdir -p $out/include
              cp -vr lib/sixense/include/. -t $out/include
              mkdir -p $out/lib
            '' +
            (if system == "i686-linux" then ''
              cp -vr lib/sixense/lib/linux/release/. -t $out/lib
            '' else ''
              cp -vr lib/sixense/lib/linux_x64/release/. -t $out/lib
            '');
          };
        };
      }
    );
}
