[
  #(import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz))
  # Use a local copy of nixpkgs-mozilla until the following bug is fixed:
  #     https://github.com/mozilla/nixpkgs-mozilla/issues/199
  (import ./nixpkgs-mozilla/default.nix)

  (import ./my-packages.nix)
  (import ./other-packages/default.nix)
]
