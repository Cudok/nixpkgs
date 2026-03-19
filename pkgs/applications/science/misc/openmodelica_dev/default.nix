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
  lapack,
  blas,
  qt6,
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
  # src = fetchgit {
  #   url = "https://github.com/OpenModelica/OpenModelica/";
  #   rev = "f10cf343dc90e6ce1eb9a0b72b01c9b6398af5c1";
  #   sha256 = "09lm9ry227xbw27cvddhsb3xxab2smzyysdb53wcl7knq6y3rrhs";
  #   fetchSubmodules = true;
  # };
# Update with: nix run -f ./nixpkgs/default.nix nix-prefetch-git -c nix-prefetch-git 'https://github.com/OpenModelica/OpenModelica/' 'v1.18.0' --fetch-submodules
#  nix-prefetch-git 'https://github.com/OpenModelica/OpenModelica/' 'v1.26.3' --fetch-submodules

 nativeBuildInputs = [
    cmake
    ccache
    gfortran
    makeWrapper
    qt6.wrapQtAppsHook
    # Add other native build tools (flex, bison, etc.)
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine  # For OM_OMEDIT_ENABLE_QTWEBENGINE=ON
    boost
    lapack
    blas
    # Add all other dependencies
  ];

  cmakeFlags = [
    "-DOM_QT_MAJOR_VERSION=6"
    "-DOM_OMEDIT_ENABLE_QTWEBENGINE=ON"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    # Add other desired options
 # Tell CMake to use pkg-config for BLAS/LAPACK
    "-DBLA_PREFER_PKGCONFIG=ON"
    "-DBLA_VENDOR=Generic"

    # Optional: specify exact package names (CMake 3.25+)
    "-DBLA_PKGCONFIG_BLAS=blas"
    "-DBLA_PKGCONFIG_LAPACK=lapack"

    # Disable NVPL search
    "-Dnvpl_DIR=IGNORE"
    "-Dnvpl_ROOT=IGNORE"
  ];

 # Add this to set up pkg-config environment
  preConfigure = ''
    # Set PKG_CONFIG_PATH to find BLAS/LAPACK .pc files
    export PKG_CONFIG_PATH="${blas}/lib/pkgconfig:${lapack}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Debug: show what pkg-config finds
    echo "=== pkg-config debug ==="
    pkg-config --list-all | grep -E 'blas|lapack' || true
    pkg-config --modversion blas || true
    pkg-config --modversion lapack || true
    echo "========================"
  '';

  meta = {
    description = "OpenModelica";
    homepage = "https://openmodelica.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
