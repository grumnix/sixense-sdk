{
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "i686-linux" "x86_64-linux" ]  (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = rec {
          default = sixense-sdk;

          sixense-sdk-full = pkgs.requireFile {
            name = "SixenseSDK";
            hashMode = "recursive";
            sha256 = "sha256-ou4fyAED6OJGb5a2JeSZIX/fbIfVUq8pEsrXN6jjBYk=";
            message = ''
              1. Download SixenseSDK from Steam:

                steam://install/42300

              2. Add SDK to /nix/store:

                nix store add-path "~/.local/share/Steam/steamapps/common/Sixense SDK/SixenseSDK/"
            '';
          };

          sixense-sdk = pkgs.stdenv.mkDerivation rec {
            name = "sixense-sdk";

            src = ./.;

            installPhase = ''
              mkdir -p $out/include
              cp -vr ${sixense-sdk-full}/include/. -t $out/include
              mkdir -p $out/lib
            '' +
            (if system == "i686-linux" then ''
              cp -vr ${sixense-sdk-full}/lib/linux/release/. $out/lib
            '' else ''
              cp -vr ${sixense-sdk-full}/lib/linux_x64/release/libsixense_x64.so \
                $out/lib/libsixense.so
              cp -vr ${sixense-sdk-full}/lib/linux_x64/release/libsixense_utils_x64.so \
                $out/lib/libsixense_utils.so
            '');
          };

          sixense-sdk-simple3d = pkgs.stdenv.mkDerivation rec {
            name = "sixense-sdk-simple3d";

            src = ./.;

            buildPhase = ''
              g++ \
                -o sixense-sdk-simple3d \
                ${sixense-sdk-full}/src/sixense_simple3d/progs/demos/sixense_simple3d/sixense_simple3d.c \
                -lGL -lGLU -lglut \
                -lsixense -lsixense_utils
            '';

            installPhase = ''
              mkdir -p $out/bin
              install sixense-sdk-simple3d $out/bin/
            '';

            buildInputs = [
              sixense-sdk

              pkgs.freeglut
              pkgs.libGL
              pkgs.libGLU
            ];
          };
        };

        apps = rec {
          default = sixense-sdk-simple3d;

          sixense-sdk-simple3d = {
            type = "app";
            program = "${packages.sixense-sdk-simple3d}/bin/sixense-sdk-simple3d";
          };
        };
      }
    );
}
