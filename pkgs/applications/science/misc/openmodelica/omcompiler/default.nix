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

  buildPhase = ''
    echo 'hello worllld' > $out
  '';
}
