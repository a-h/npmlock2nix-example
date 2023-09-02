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
          name = "zero-to-nix-javascript";

          buildInputs = with pkgs; [
            nodejs-18_x
          ];

          src = ./.;

          npmBuild = "npm run build";

          npmDepsHash = "sha256-s1Kze9LuYSDVxm1jxMG1yoGCYVRBsnwJ0Zi0NcT5lzg=";

          installPhase = ''
            mkdir -p $out
            cp dist/* $out
            cp hello.sh $out/hello
            chmod +x $out/hello
          '';
        };
      });
    };
}
