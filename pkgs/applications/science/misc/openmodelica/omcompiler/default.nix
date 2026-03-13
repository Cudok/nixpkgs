{
  stdenv,
  lib,
  gfortran,
}:
# pkg:
let
  test_a = "test_a";
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
