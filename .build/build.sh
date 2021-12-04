#!/bin/bash
set -e

#----------------------------------------
# BUILD API REPO INDICES (using Docker)
#----------------------------------------
cp ~/.gnupg/homeseer.key .   # copy local homeseer PGP private key to to use during build

# build HOMESEER.SH debian installer packages
docker run --rm --volume $(pwd):/build pi4j/pi4j-builder-repo:latest .build/build-debs.sh

# build HOMESEER.SH [V4] distribution APT repository metadata
docker run --rm --volume $(pwd):/build pi4j/pi4j-builder-repo:latest .build/build-repo-v4.sh

rm homeseer.key              # remove local copy of homeseer PGP private key
