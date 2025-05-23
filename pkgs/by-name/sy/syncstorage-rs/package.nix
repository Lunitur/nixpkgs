{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  python3,
  cmake,
  libmysqlclient,
  makeBinaryWrapper,
  lib,
  nix-update-script,
}:

let
  pyFxADeps = python3.withPackages (p: [
    p.setuptools # imports pkg_resources
    # remainder taken from requirements.txt
    p.pyfxa
    p.tokenlib
    p.cryptography
  ]);
in

rustPlatform.buildRustPackage rec {
  pname = "syncstorage-rs";
  version = "0.18.2";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "syncstorage-rs";
    tag = version;
    hash = "sha256-YIj9yoZrVRMcWFczyy5RR2Djwhu1/CyQuumzPoApp3I=";
  };

  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
    pkg-config
    python3
  ];

  buildInputs = [
    libmysqlclient
  ];

  preFixup = ''
    wrapProgram $out/bin/syncserver \
      --prefix PATH : ${lib.makeBinPath [ pyFxADeps ]}
  '';

  useFetchCargoVendor = true;
  cargoHash = "sha256-POm9JMv6sPIl00HzKoVJPUdvRcmBpsB/fbG/JmjePPM=";

  # almost all tests need a DB to test against
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mozilla Sync Storage built with Rust";
    homepage = "https://github.com/mozilla-services/syncstorage-rs";
    changelog = "https://github.com/mozilla-services/syncstorage-rs/releases/tag/${version}";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "syncserver";
  };
}
