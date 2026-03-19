{
  stdenv,
  lib,
  # fetchgit,
  fetchFromGitHub,
  cmake,
  ccache,
  makeWrapper,
  pkg-config,
  gfortran,
  boost,
  openblas,
  qt6,
  autoconf,
  automake,
  libtool,
  m4,
  which,
  jdk11,
  ...
}:

let
in
stdenv.mkDerivation rec {
  name = "om_dev";
  version = "v1.26.3";
  src = fetchFromGitHub {
      owner = "OpenModelica";
      repo = "OpenModelica";
      rev = "${version}";
      sha256 = "sha256-GuY8vMF2Hsr4KKtp73/VYqnex9Kwtc2O4KsfIXxOlSY=";
      fetchSubmodules = true;
    };
# Update with: nix run -f ./nixpkgs/default.nix nix-prefetch-git -c nix-prefetch-git 'https://github.com/OpenModelica/OpenModelica/' 'v1.18.0' --fetch-submodules
#  nix-prefetch-git 'https://github.com/OpenModelica/OpenModelica/' 'v1.26.3' --fetch-submodules

 nativeBuildInputs = [
    cmake
    ccache
    gfortran
    makeWrapper
    qt6.wrapQtAppsHook
    autoconf
    automake
    libtool
    m4
    jdk11
    which
    # Add other native build tools (flex, bison, etc.)
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine  # For OM_OMEDIT_ENABLE_QTWEBENGINE=ON
    boost
    openblas
    # Add all other dependencies
  ];

  cmakeFlags = [
    "-DOM_QT_MAJOR_VERSION=6"
    "-DOM_OMEDIT_ENABLE_QTWEBENGINE=ON"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    # Add other desired options
    #
    # OpenBLAS configuration
    "-DBLA_VENDOR=OpenBLAS"
    "-DBLAS_LIBRARIES=${openblas}/lib/libopenblas.so"
    "-DLAPACK_LIBRARIES=${openblas}/lib/libopenblas.so"
    "-DBLA_PREFER_PKGCONFIG=ON"

    # Disable NVPL search
    "-Dnvpl_DIR=IGNORE"
    "-Dnvpl_ROOT=IGNORE"

    # Disable OpenCL (optional, requires hardware support)
    "-DOM_OMC_ENABLE_OPENCL=OFF"
  ];

 # Add this to set up pkg-config environment
# Add this to preConfigure to see what libraries are available
preConfigure = ''
  # Set up pkg-config for openblas
    export PKG_CONFIG_PATH="${openblas}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Set library paths
    export BLAS_LIBRARIES="${openblas}/lib/libopenblas.so"
    export LAPACK_LIBRARIES="${openblas}/lib/libopenblas.so"

  # Verify Java is available
  echo "=== Java verification ==="
  java -version
  javac -version
  which java
  which javac
  echo "=========================="
'';

  meta = {
    description = "OpenModelica";
    homepage = "https://openmodelica.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
