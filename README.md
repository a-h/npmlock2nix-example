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
