# mkOpenModelicaDerivation is an mkDerivation function for packages
# from OpenModelica suite.

{
  stdenv,
  lib,
  fetchgit
}:
pkg:
let
  test = "test";
in
stdenv.mkDerivation (
  pkg
  // {
    name = pkg.pname;
    # to change the version (source code) of openmodelica adpat src-main.nix
    src = fetchgit (import ./src-main.nix);
    version = "1.26.3";

  }
)
