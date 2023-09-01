{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  };

  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.buildNpmPackage {
          name = "buildNpmPackage-example";

          buildInputs = with pkgs; [
            nodejs-18_x
          ];

          src = ./.;
          npmDepsHash = "sha256-o8ZcUbUhR2OH3gGRZwKtHfc8FllbG/QZ84T0Kivz8qM=";

          installPhase = ''
            mkdir -p $out
            cp index.js $out/index.js
            cp hello.sh $out/hello
            chmod +x $out/hello
          '';
        };
      });
    };
}
