{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "git-side";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Solexma";
    repo = "git-side";
    rev = "v${version}";
    hash = "sha256-oHkVWqY6gv9WQaJLUmbW3TNsaRpxfw1R3udo7dFsf+o=";
  };

  cargoHash = "sha256-XUA+WTKcbeMivYb8Z+hi7GaNkpyk38DBzkuC4+6zTqc=";

  meta = {
    description = "Version files and directories that should not live in the main repo.";
    mainProgram = "git-side";
    homepage = "https://github.com/Solexma/git-side";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdorman ];
    platforms = lib.platforms.all;
  };
}
