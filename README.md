# npmlock2nix example

This is an example showing that the `nix copy` operation doesn't copy the non-flake inputs to the output directory.

## Reproduction

Copy the derivation and the outputs to the export directory.

```shell
nix copy --derivation --to file://$PWD/export
nix copy --to file://$PWD/export
```

Next, look at the narinfo files. I've added a PR to gonix to support this.

```
ls ./export/*.narinfo | xargs -I {} gonix narinfo info {} | grep StorePath
```

The output of this command is present in the ./exports.txt file. Note that it doesn't contain the non-flake input `npmlock2nix`, or any of its dependencies.

## Test rebuild in airgap

First, built the `nixpkgs-offline` Docker container in https://github.com/a-h/nix-airgapped-copy/

Then, run it with no network, mounting in the code in this repo.

```
docker run -it --rm --network none -v `pwd`/export:/home/nix/export -v `pwd`:/example-flake nixpkgs-offline
```

Copy all the export files into the container.

```
nix copy --all --derivation --from file:///home/nix/export/ --no-check-sigs --verbose
```

Try to build the flake.

```
cd /example-flake
nix build
```

It's expected to build, but actually fails, attempting to rebuild `curl`.

```
nix@7ca4a643d83c:/example-flake$ nix build
warning: you don't have Internet access; disabling some network-dependent features
warning: Git tree '/example-flake' is dirty
error:
       … while calling the 'import' builtin

         at /nix/store/j2v90ma89c9bymqwzbdy3b0a67rdbhgd-source/flake.nix:13:16:

           12|       pkgs = nixpkgs.legacyPackages."x86_64-linux";
           13|       nl2nix = import npmlock2nix {inherit pkgs;};
             |                ^
           14|       app = nl2nix.v2.build {

       … while calling the 'fetchTree' builtin

         at «string»:16:18:

           15|             then rootSrc
           16|             else fetchTree (node.info or {} // removeAttrs node.locked ["dir"]);
             |                  ^
           17|

       (stack trace truncated; use '--show-trace' to show the full trace)

       error: unable to download 'https://github.com/nix-community/npmlock2nix/archive/9197bbf397d76059a76310523d45df10d2e4ca81.tar.gz': Couldn't resolve host name (6)
```
