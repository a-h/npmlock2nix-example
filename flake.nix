{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    npmlock2nix = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, npmlock2nix }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      nl2nix = import npmlock2nix {inherit pkgs;};
      app = nl2nix.v2.build {
        src = ./.;
        nodejs = pkgs.nodejs-18_x;
        buildCommands = [ "HOME=$PWD" "npm run build" ];
        installPhase = ''
        mkdir -p $out
          cp index.js $out/index.js
          cp hello.sh $out/hello
          chmod +x $out/hello
        '';
      };
    in
    {
      packages."x86_64-linux".default = app;
    };
}

