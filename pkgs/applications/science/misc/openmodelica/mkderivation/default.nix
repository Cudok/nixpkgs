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
stdenv.mkDerivation {
  name = pkg.pname;
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
