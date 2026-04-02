{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  npmHooks,
  nix-update-script,
}:
let
  pnpm = pnpm_11;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rulesync";
  version = "26.0.0";

  src = fetchFromGitHub {
    owner = "dyoshikawa";
    repo = "rulesync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NFm/2G6bRQg6/aSkv+Yz6EMdg4I+ohUx+16D63ZOTIQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = if stdenv.hostPlatform.system == "aarch64-darwin" then "sha256-5MQvxvTQ2GlIStgd69kSrelntpBY5LvcvRoh65A9pE8=" else "sha256-EVbUxDwZ7vrgzyK+l5B+uEaBHr3lOkaWom7/ghJAy/8=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    npmHooks.npmInstallHook
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  dontNpmPrune = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unified AI rules management CLI tool for AI coding assistants";
    longDescription = ''
      Rulesync is a CLI tool designed to centralize and automate the management of configuration files
      for various AI development tools (Cursor, Claude Code, GitHub Copilot, etc.).
      It allows maintaining a single set of unified rule files and syncing them across multiple AI ecosystems.
    '';
    homepage = "https://github.com/dyoshikawa/rulesync";
    changelog = "https://github.com/dyoshikawa/rulesync/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ "mdorman" ];
    mainProgram = "rulesync";
    platforms = nodejs.meta.platforms;
  };
})
