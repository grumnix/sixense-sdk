{
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    sixense-sdk-full.url = "github:grumnix/sixense-sdk-full";
    sixense-sdk-full.inputs.nixpkgs.follows = "nixpkgs";
    sixense-sdk-full.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, sixense-sdk-full }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]  (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = sixense-sdk;

          sixense-sdk = pkgs.stdenv.mkDerivation rec {
            pname = "sixense-sdk";
            version = "0.0";

            src = ./.;

            buildPhase = ''
              g++ \
                -o sixense-sdk-simple3d \
                ${sixense-sdk-full.packages.${system}.default}/src/sixense_simple3d/progs/demos/sixense_simple3d/sixense_simple3d.c \
                -I${sixense-sdk-full.packages.${system}.default}/include \
                -lGL -lGLU -lglut \
            '' +
            (if system == "i686-linux"
             then ''-L${sixense-sdk-full.packages.${system}.default}/lib/linux/release -lsixense -lsixense_utils''
             else ''-L${sixense-sdk-full.packages.${system}.default}/lib/linux_x64/release -lsixense_x64 -lsixense_utils_x64'');

            installPhase = ''
              mkdir -p $out/bin
              install sixense-sdk-simple3d $out/bin/

              mkdir -p $out/include
              cp -vr ${sixense-sdk-full.packages.${system}.default}/include/. -t $out/include
              mkdir -p $out/lib
            '' +
            (if system == "i686-linux" then ''
              cp -vr ${sixense-sdk-full.packages.${system}.default}/lib/linux/release/. $out/lib
            '' else ''
              cp -vr ${sixense-sdk-full.packages.${system}.default}/lib/linux_x64/release/libsixense_x64.so \
                $out/lib/libsixense.so
              cp -vr ${sixense-sdk-full.packages.${system}.default}/lib/linux_x64/release/libsixense_utils_x64.so \
                $out/lib/libsixense_utils.so
            '');

            buildInputs = [
              pkgs.freeglut
              pkgs.libGL
              pkgs.libGLU
            ];
          };
        };
      }
    );
}
