{}:
let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "myPackage";
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
