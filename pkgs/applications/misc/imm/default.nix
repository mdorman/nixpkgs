{ stdenv, ghcWithPackages, makeWrapper, packages ? (pkgSet: []) }:

let
  immEnv = ghcWithPackages (self: [ self.imm ] ++ packages self);
in stdenv.mkDerivation {
  name = "imm-with-packages-${immEnv.version}";

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin $out/share
    makeWrapper ${immEnv}/bin/imm $out/bin/imm \
      --set NIX_GHC "${immEnv}/bin/ghc"
  '';

  # trivial derivation
  preferLocalBuild = true;
  allowSubstitutes = false;
}
