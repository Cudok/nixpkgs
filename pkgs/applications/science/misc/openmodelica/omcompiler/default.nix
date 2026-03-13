{
  stdenv,
  lib,
  gfortran,
  mkOpenModelicaDerivation,
}:
# pkg:
let
  test_a = "test_a";
in

mkOpenModelicaDerivation
  {
    pname = "omcompiler";
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
