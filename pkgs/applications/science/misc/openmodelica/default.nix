{
  lib,
  newScope,
  # libsForQt5, only as reminder, TODO delete later
  clangStdenv,
}:
lib.makeScope newScope (
  self:
  let
    # separate name space (eg. openmodica.omcompiler)
    callPackage = self.newScope {stdenv = clangStdenv; };
  in
    {
      mkOpenModelicaDerivation = callPackage ./mkderivation { } ;
      omcompiler = callPackage ./omcompiler { } ;
    }
)



# pkgs.stdenv.mkDerivation {
#   name = "openmodelica_qt6";
#   src = ./.;

#   # buildInputs = [
#   #   pkgs.ffmpeg
#   # ];
#   # # only for the build process
#   # nativeBuildInputs = [
#   #   pkgs.pkgs.config
#   # ];
#   # unpackPhase = '' # shell logic '';
#   buildPhase = ''
#     echo 'hello worllld' > $out
#   '';
#   # installPhase = '' # shell logic '';
#   # ...
# }
