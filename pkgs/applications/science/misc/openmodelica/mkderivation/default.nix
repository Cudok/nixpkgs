# mkOpenModelicaDerivation is an mkDerivation function for packages
# from OpenModelica suite.

{
  stdenv,
  lib,
  fetchgit
}:
let
  pkgs = import <nixpkgs> {};
in
stdenv.mkDerivation {
  name = "mkOpenDerivation";
  src = ./.;

  # buildInputs = [
  #   pkgs.ffmpeg
  # ];
  # # only for the build process
  # nativeBuildInputs = [
  #   pkgs.pkgs.config
  # ];
  # unpackPhase = '' # shell logic '';
  buildPhase = ''
    echo 'hello worllld' > $out
  '';
  # installPhase = '' # shell logic '';
  # ...
}
