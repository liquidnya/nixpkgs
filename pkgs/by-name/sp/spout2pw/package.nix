{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  libdrm,
  cmake,
  dbus,
  pkgsCross,
  wine64,
  buildPackages,
  mesa,
  fftwFloat,
  pipewire,
}:
let
  pipewire-static = src: stdenv.mkDerivation (finalAttrs: {
    name = "pipewire-static";
    src = "${src}/subprojects/pipewire-static";
    strictDeps = true;
    __structuredAttrs = true;
  
  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    libdrm
    fftwFloat
  ];
  buildInputs = [
    dbus
  ];
  mesonAutoFeatures = "disabled";
    mesonFlags = [
        (lib.mesonEnable "examples" false)
        (lib.mesonEnable "tests" false)
        (lib.mesonEnable "gstreamer" false)
        (lib.mesonEnable "libsystemd" false)
        (lib.mesonEnable "logind" false)
        (lib.mesonEnable "selinux" false)
        (lib.mesonEnable "pipewire-alsa" false)
        (lib.mesonEnable "pipewire-jack" false)
        (lib.mesonEnable "pipewire-v4l2" false)
        (lib.mesonEnable "spa-plugins" true)
        (lib.mesonEnable "udev" false)
        (lib.mesonEnable "sdl2" false)
        (lib.mesonEnable "v4l2" false)
        (lib.mesonEnable "alsa" false)
        (lib.mesonEnable "x11" false)
        (lib.mesonEnable "libffado" false)
        (lib.mesonEnable "snap" false)
        (lib.mesonEnable "opus" false)
        (lib.mesonEnable "readline" false)
        (lib.mesonEnable "gsettings" false)
        (lib.mesonOption "session-managers" "'[]'")
        (lib.mesonOption "default_library" "static")
        (lib.mesonEnable "jack" false)
        (lib.mesonEnable "avahi" false)
        (lib.mesonEnable "pipewire-alsa" false)
        (lib.mesonEnable "raop" false)
        (lib.mesonEnable "avb" false)
        (lib.mesonEnable "libpulse" false)
        (lib.mesonEnable "flatpak" false)
        (lib.mesonEnable "support" true)
        (lib.mesonOption "static" "true")
    ];
  });
in
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
    meson
    ninja
    cmake
    pkgsCross.mingwW64.buildPackages.gcc
    wine64
  ];

  depsBuildBuild = [
    buildPackages.pkg-config
    buildPackages.libgbm
    buildPackages.libdrm
    buildPackages.vulkan-loader
    buildPackages.pipewire
  ];

  patches = [
    ./0001-use-env-over-native-txt.patch
    ./0002-fix-gbm.patch
    ./0003-set-spout2pw-path.patch
    ./0004-fix-pkgdir.patch
    ./0005-pipewire.patch
  ];

  postPatch = ''
    # patchShebangs only works if the script is executable
    chmod +x tools/package.sh

    patchShebangs --build tools/get_wine_path.sh
    patchShebangs --build tools/package.sh
  '';

  mesonFlags = [
    "--cross-file=${finalAttrs.src}/misc/x86_64-w64-mingw32.txt"
  ];

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/share/spout2pw/spout2pw.sh $out/bin/spout2pw
  '';

  postFixup = ''
    substituteInPlace $out/share/spout2pw/spout2pw.sh \
      --replace-fail '@MESA_PATH@' "${mesa}" \
      --replace-fail '@SPOUT2PW_PATH@' "$out"
  '';

  passthru = {
    pipewire-static = (pipewire-static finalAttrs.src);
  };

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
