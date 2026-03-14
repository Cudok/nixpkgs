# mkOpenModelicaDerivation is an mkDerivation function for packages
# from OpenModelica suite.

{
  stdenv,
  lib,
  fetchgit,
  symlinkJoin,
}:
pkg:
let
  inherit (builtins)
    hasAttr
    getAttr
    length
    elemAt
    ;
  inherit (lib) attrByPath concatStringsSep;

  # A few helpers functions:

  # getAttrDef is just a getAttr with default fallback
  getAttrDef =
    attr: default: x:
    attrByPath [ attr ] default x;

  # getAttr-like helper for optional append to string:
  # "Hello" + appendByAttr "a" " " {a = "world";} = "Hello world"
  # "Hello" + appendByAttr "a" " " {} = "Hello"
  appendByAttr =
    attr: sep: x:
    lib.optionalString (hasAttr attr x) (sep + (getAttr attr x));

  # Are there any OM dependencies at all?
  ifDeps = length pkg.omdeps != 0;

  joinedDeps =
    if length pkg.omdeps == 1 then
      elemAt pkg.omdeps 0
    else
      symlinkJoin {
        name = pkg.pname + "-omhome";
        paths = pkg.omdeps;
      };

  # Should we run ./configure for the target pkg?
  omautoconf = getAttrDef "omautoconf" false pkg;

  # Name of the make target
  omtarget = getAttrDef "omtarget" pkg.pname pkg;

  # Directory of target sources
  omdir = getAttrDef "omdir" pkg.pname pkg;

  # Simple to to m4 configuration scripts
  postPatch =
    lib.optionalString ifDeps ''
      sed -i ''$(find -name omhome.m4) -e 's|if test ! -z "$USINGPRESETBUILDDIR"|if test ! -z "$USINGPRESETBUILDDIR" -a -z "$OMHOME"|'
    ''
    + appendByAttr "postPatch" "\n" pkg;

  # Update shebangs in the scripts before running configuration. adapt the nix
  # paths of needed tools (like e.g. python)
  preAutoreconf = "patchShebangs --build common" + appendByAttr "preAutoreconf" "\n" pkg;

  # Tell OpenModelica where built dependencies are located.
  configureFlags =
    lib.optional ifDeps "--with-openmodelicahome=${joinedDeps}" ++ getAttrDef "configureFlags" [ ] pkg;

  # Our own configurePhase that accounts for omautoconf
  configurePhase = ''
    runHook preConfigure
    # Debug: print
    export configureFlags="''${configureFlags} --with-ombuilddir=$PWD/build --prefix=$prefix"
    ./configure --no-recursion $configureFlags
    ${lib.optionalString omautoconf "(cd ${omdir}; ./configure $configureFlags)"}
    runHook postConfigure
  '';

  # Targets that we want to build ourselves:
  deptargets = lib.forEach pkg.omdeps (dep: dep.omtarget);

  # ... so we ask openmodelica makefile to skip those targets.
  preBuild = ''
    for target in ${concatStringsSep " " deptargets}; do
      touch ''${target}.skip;
    done
  ''
  + appendByAttr "preBuild" "\n" pkg;

in
stdenv.mkDerivation (
  pkg
  // {
    # link the args from let ... in
    inherit
      preAutoreconf
      omtarget
      postPatch
      configureFlags
      configurePhase
      preBuild
      ;
    # name = pkg.pname;
    # to change the version (source code) of openmodelica adpat src-main.nix
    src = fetchgit (import ./src-main.nix);
    version = "1.26.3";

  }
)
