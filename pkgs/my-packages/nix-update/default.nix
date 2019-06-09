{ stdenv, ... }:

stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/bin
    cp ${scriptFile} $out/bin/nix-update
  '';

  meta = {
    description = "A script to aid in updating nix expressions";
    license     = stdenv.lib.licenses.gpl3;
  };

  name = "nix-update-${version}";

  phases = [ "installPhase" "fixupPhase" ];

  scriptFile = builtins.toFile "nix-update" ''
    #!/bin/sh
    NIXPKGS=/var/nixup/nixpkgs
    EXPRESSION=$1
    if [ -z "$EXPRESSION" ]; then
        echo "Building system"
        output=$(nixos-rebuild --no-build-output dry-build 2>&1)
        if [ $? != 0 ]; then
            printf "Error during build:\n%s" "$output"
            read -p "Press enter to continue" yn
        elif echo "$output" | egrep -q '^[[:space:]]+'; then
            echo "$output"
            read -p "Do you want to do the upgrade (y)? " yn
            case $yn in
                [Nn]* )
                    exit
                    ;;
                *     )
                    sudo nixos-rebuild --no-build-output switch
                    if [ $? != 0 ]; then
                        read -p "Press enter to continue" yn
                    fi
                    break
                    ;;
            esac
        else
            echo "Nothing to download or build"
        fi
    else
        echo "Building $EXPRESSION"
        output=$(nix-env --file $NIXPKGS --install --no-build-output --dry-run $EXPRESSION 2>&1)
        if [ $? != 0 ]; then
            printf "Error during build:\n%s" "$output"
            read -p "Press enter to continue" yn
        elif echo "$output" | egrep -q '^[[:space:]]+'; then
            echo "$output"
            read -p "Do you want to do the install (y)? " yn
            case $yn in
                [Nn]* )
                    exit
                    ;;
                *     )
                    nix-env --file $NIXPKGS --install --keep-going --no-build-output $EXPRESSION
                    if [ $? != 0 ]; then
                        read -p "Press enter to continue" yn
                    fi
                    break
                    ;;
            esac
        else
            echo "Nothing to download or build"
        fi
    fi
  '';

  version = "1";
}
