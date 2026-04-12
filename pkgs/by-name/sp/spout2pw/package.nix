{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  libdrm,
  vulkan-loader,
  cmake,
  dbus,
  pkgsCross,
  wine64,
  libgbm,
  mesa,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spout2pw";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "hoshinolina";
    repo = "spout2pw";
    rev = finalAttrs.version;
    fetchSubmodules = true;
    sha256 = "sha256-BpO5YkLPXHYubB4zFIIRo+uDcN/B6HWXyH6FUCF0T3s=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkgsCross.mingwW64.buildPackages.gcc
    dbus
    wine64
  ];

  depsBuildBuild = [
    pkg-config
    libgbm
    libdrm
    vulkan-loader
  ];

  dontConfigure = true;

  patches = [
    ./0001-use-env-over-native-txt.patch
    ./0002-fix-gbm.patch
    ./0003-set-spout2pw-path.patch
  ];

  postPatch = ''
    patchShebangs --build build.sh
    patchShebangs --build tools/get_wine_path.sh
    # patchShebangs only works if the script is executable
    chmod +x tools/package.sh
    patchShebangs --build tools/package.sh
  '';

  buildPhase = ''
    runHook preBuild

    ./build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/spout2pw
    cp -r ./build/pkg/* $out/share/spout2pw

    mkdir -p $out/bin
    ln -s $out/share/spout2pw/spout2pw.sh $out/bin/spout2pw

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/spout2pw/spout2pw.sh \
      --replace-fail '@MESA_PATH@' "${mesa}" \
      --replace-fail '@SPOUT2PW_PATH@' "$out"
  '';

  meta = {
    description = "Spout2 to PipeWire video bridge";
    homepage = "https://spout2pw.lina.yt/";
    mainProgram = "spout2pw";
    maintainers = with lib.maintainers; [
      liquidnya
    ];
    license = lib.licenses.lgpl21Plus;
  };
})
