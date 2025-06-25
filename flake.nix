{
  description = "Raylib development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    buildInputs = with pkgs; with xorg; [
      libGL
      libX11
      libX11.dev
      libXcursor
      libXi
      libXinerama
      libXrandr
    ];

    nativeBuildInputs = with pkgs; [
      clang
      mold
      pkg-config
      gnumake
    ];

    devTools = with pkgs; [
      # emscripten
      clang-tools
      bear
    ];
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
    INCLUDE_PATH = pkgs.lib.makeIncludePath buildInputs;

  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = buildInputs ++ nativeBuildInputs ++ devTools;
      shellHook = ''
        export CC=clang
        export CXX=clang++
        export LD=clang
        export CFLAGS="-fuse-ld=mold"
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${LD_LIBRARY_PATH}
        export INCLUDE_PATH=$INCLUDE_PATH:${INCLUDE_PATH}
      '';
    };

    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "raylib-nixos";
      src = ./.;
      inherit buildInputs nativeBuildInputs;

      buildPhase = ''
        make MODE=release
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp bin/game $out/bin/
      '';

      postInstall = ''
        wrapProgram $out/bin/game --prefix LD_LIBRARY_PATH : ${LD_LIBRARY_PATH}
      '';

      installCheckPhase = "true";
      meta = {
        description = "Raylib demo";
        platforms = [ "x86_64-linux" ];
        mainProgram = "game";
      };
    };

    apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/game";
    };

    defaultPackage = self.packages.${system}.default;
    defaultApp = self.apps.${system}.default;

  };
}
