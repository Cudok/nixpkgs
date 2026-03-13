{
  stdenv,
  lib,
  gfortran,
  flex,
  bison,
  jre8,
  blas,
  lapack,
  curl,
  readline,
  expat,
  pkg-config,
  buildPackages,
  targetPackages,
  libffi,
  binutils,
  mkOpenModelicaDerivation,
}:
# pkg:
let
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;
  nativeOMCompiler = buildPackages.openmodelica.omcompiler;
in

mkOpenModelicaDerivation (
  {
    pname = "omcompiler";
    omtarget = "omc";
    omdir = "OMCompiler";
    omdeps = [ ];
    omautoconf = true;

    nativeBuildInputs = [
      jre8
      gfortran
      flex
      bison
      pkg-config
    ]
    ++ lib.optional isCross nativeOMCompiler;

    buildInputs = [
      targetPackages.stdenv.cc.cc
      blas
      lapack
      curl
      readline
      expat
      libffi
      binutils
    ];

    # scipted modification of Makefiles to use cross-compiles tools instead of
    # native tools
    postPatch = ''
      sed -i -e '/^\s*AR=ar$/ s/ar/${stdenv.cc.targetPrefix}ar/
                 /^\s*ar / s/ar /${stdenv.cc.targetPrefix}ar /
                 /^\s*ranlib/ s/ranlib /${stdenv.cc.targetPrefix}ranlib /' \
          $(find ./OMCompiler -name 'Makefile*')
    '';
    # set flags to supress error breaks
    env.CFLAGS = toString [
      "-Wno-error=dynamic-exception-spec"
      "-Wno-error=implicit-function-declaration"
    ];

    # find libipopt and make it availble for nix
    preFixup = ''
      for entry in $(find $out -name libipopt.so); do
        patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$entry"
        patchelf --set-rpath '$ORIGIN':"$(patchelf --print-rpath $entry)" "$entry"
      done
    '';

    # everything optional, no impact to the build process
    meta = {
      description = "Modelica compiler from OpenModelica suite";
      homepage = "https://openmodelica.org";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [
        balodja
        smironov
      ];
      platforms = lib.platforms.linux;
    };
  }
  # add/merge configuration flage in case of cross compiling
  // lib.optionalAttrs isCross {
    configureFlags = [ "--with-omc=${nativeOMCompiler}/bin/omc" ];
  }
)
