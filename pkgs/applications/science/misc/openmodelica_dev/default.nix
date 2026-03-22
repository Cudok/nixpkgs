{
  stdenv,
  lib,
  fetchurl,
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
  curl,
  zlib,
  libossp_uuid,
  readline,
  openscenegraph,
  flex,
  bison,
  ...
}:

let
  # Pre-fetch the bootstrapping sources
  # needed because network not availble will configuration phase
  ombootstrappingTarball = fetchurl {
    url = "https://github.com/OpenModelica/OMBootstrapping/archive/f53f31420ab8a1877b1a423693599028df698e14.tar.gz";
    hash = "sha256-/NkCIUcqZZjeUf/IOEEWCa+gmpFdxlpr1wTuVv5QvBU=";
  };
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
    flex
    bison
    # Add other native build tools (flex, bison, etc.)
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine  # For OM_OMEDIT_ENABLE_QTWEBENGINE=ON
    boost
    openblas
    curl
    zlib
    libossp_uuid
    qt6.qt5compat
    qt6.qttools
    readline
    # 3D visualization
    openscenegraph
    # Add all other dependencies
  ];

  cmakeFlags = [
    "-DOM_QT_MAJOR_VERSION=6"
    "-DOM_OMEDIT_ENABLE_QTWEBENGINE=ON"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    # Add other desired options
    # make find pkg-config
    "-DPKG_CONFIG_EXECUTABLE=${pkg-config}/bin/pkg-config"
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

  # Setup ccache to use a writable directory
    export CCACHE_DIR="$TMPDIR/ccache"
    mkdir -p "$CCACHE_DIR"

  # Set up environment
    export PKG_CONFIG_PATH="${openblas}/lib/pkgconfig:${curl}/lib/pkgconfig:${zlib}/lib/pkgconfig:$PKG_CONFIG_PATH"
  # Handle bootstrapping sources
    mkdir -p OMCompiler/Compiler/boot/bomc

  # Copy and extract the bootstrapping tarball
    cp ${ombootstrappingTarball} OMCompiler/Compiler/boot/bomc/sources.tar.gz

  # Extract it (since CMake skips extraction when the file exists)
    cd OMCompiler/Compiler/boot/bomc
    tar xzf sources.tar.gz --strip-components=1
    cd ../../../..

  # Verify the header exists
    if [ ! -f OMCompiler/Compiler/boot/bomc/tarball-include/OpenModelicaBootstrappingHeader.h ]; then
      echo "Error: Bootstrapping header not found!"
      find OMCompiler/Compiler/boot/bomc -name "*.h" || true
      exit 1
    fi

    echo "Bootstrapping sources prepared successfully"

 # For pkg-config debugging
    echo "=== pkg-config check ==="
    ${pkg-config}/bin/pkg-config --version || echo "pkg-config not found!"
    echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"


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

  # Create a pkg-config symlink for ossp-uuid
    export PKG_CONFIG_PATH="${libossp_uuid}/lib/pkgconfig:$PKG_CONFIG_PATH"

  # Your existing -isystem transformation
    export NIX_CFLAGS_COMPILE=$(echo "$NIX_CFLAGS_COMPILE" | sed 's/-isystem /-I/g')
'';

postInstall = ''
  # Fix pkg-config files to avoid double slashes
  find "$out/lib/omc/pkgconfig" -name "*.pc" -type f | while read -r pc; do
    echo "Fixing $pc"
    sed -i 's|//|/|g' "$pc"
    # Also fix any duplicate store path issues
    sed -i 's|/nix/store/[^/]*/nix/store/|/nix/store/|g' "$pc"
  done

 # Wrap binaries (works for both ELF and scripts)
  LIB_PATH="$out/lib/omc:$out/lib:$out/lib/omc/cpp"

  for prog in $out/bin/*; do
    if [ -f "$prog" ] && [ -x "$prog" ]; then
      echo "Wrapping $prog"
      wrapProgram "$prog" \
        --set LD_LIBRARY_PATH "$LIB_PATH" \
        --prefix PATH : "${jdk11}/bin" \
        --set JAVA_HOME "${jdk11}"
    fi
  done

'';

  meta = {
    description = "OpenModelica";
    homepage = "https://openmodelica.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
