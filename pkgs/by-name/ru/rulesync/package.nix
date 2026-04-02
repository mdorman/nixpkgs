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
  version = "16.9.1";

  src = fetchFromGitHub {
    owner = "dyoshikawa";
    repo = "rulesync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c3S0AVf9Xx9SdhhMggYXb5TFFj+LlJSz48b5MQiOXtI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-5fyTmIFxCSOhdCK8I3Vk/f+Dj2u728yFPuEkZVFP1ig=";
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
