#!/bin/bash
set -e

# clean and create working directories
echo "[*] Removing [tmp] temporary working directory & files"
rm -R tmp || true

ARCHIVE_DIRECTORY=archive
ARCHIVE_FILE_FILTER_PREFIX="linux_[0-9]*\_[0-9]*_[0-9]*_[0-9]*"
ARCHIVE_FILE_FILTER_EXTENSION=".tar.gz"
ARCHIVE_FILE_FILTER="${ARCHIVE_FILE_FILTER_PREFIX}${ARCHIVE_FILE_FILTER_EXTENSION}"

DEB_FILE_PREFIX="homeseer-"
DEB_FILE_EXTENSION=".deb"

# ------------------------------------------
# BUILD DEBIAN PACKAGE
# ------------------------------------------
# ARG1 : version string
# ARG2 : archive file
# ARG3 : debian package file
# ------------------------------------------
buildDebianPackage () {
  # create variables from function arguments
  VERSION=$1
  ARCHIVE_FILE=$2
  DEB_FILE=$3
  TARGET=$4

  echo "[*] Build Debian package [$DEB_FILE] for version [$VERSION] from [$ARCHIVE_FILE]"

  # create temporary target working directory
  mkdir -p tmp/${TARGET}

  # copy debian control files for deb package
  cp -R .build/DEBIAN tmp/${TARGET}

  # update script permissions
  chmod -R 0755 tmp/${TARGET}/DEBIAN/postinst
  chmod -R 0755 tmp/${TARGET}/DEBIAN/preinst
  chmod -R 0755 tmp/${TARGET}/DEBIAN/postrm
  chmod -R 0755 tmp/${TARGET}/DEBIAN/prerm

  # replace version token in control file with actual version
  sed -i "s/__VERSION__/${VERSION}/g" "tmp/${TARGET}/DEBIAN/control"

  # create the target folder and extract homeseer files
  mkdir -p tmp/${TARGET}/opt

  # extract homeseer files from distribution archive
  tar xvf $ARCHIVE_FILE -C tmp/${TARGET}/opt

  # copy the service scripts to the working directory
  cp .build/scripts/*.sh tmp/${TARGET}/opt/HomeSeer
  chmod +x tmp/${TARGET}/opt/HomeSeer/*.sh

  # copy the homseer.service config file to the working directory
  cp -R .build/etc tmp/${TARGET}

  # build debian install package
  dpkg-deb --build tmp/${TARGET}

  # copy the final debian package file to the root directory
  cp tmp/${TARGET}.deb .
}

# ------------------------------------------
# SCAN FILE SYSTEM FOR [RELEASE] ARCHIVES
# ------------------------------------------

# iterate over archive files
for ARCHIVE_FILE in $ARCHIVE_DIRECTORY/release/$ARCHIVE_FILE_FILTER; do

  # extract version from filename
  VERSION="${ARCHIVE_FILE}"
  VERSION="${VERSION#*_}" # remove characters before and including first underscore
  VERSION="${VERSION%${ARCHIVE_FILE_FILTER_EXTENSION}*}" # remove file extension suffix
  VERSION="${VERSION//_/.}"  # replace underscores with dots in version string

  # build debian package file name
  DEB_FILENAME="${DEB_FILE_PREFIX}${VERSION}-release"
  DEB_FILE="${DEB_FILENAME}${DEB_FILE_EXTENSION}"

  echo "Discovered version [$VERSION] from [$ARCHIVE_FILE]; searching for [$DEB_FILE]"

  if [[ ! -e $DEB_FILE ]]; then
    echo "[+] Debian package [$DEB_FILE] does not exist; building it now ..."
    buildDebianPackage $VERSION $ARCHIVE_FILE $DEB_FILE $DEB_FILENAME
  else
    echo "[-] Debian package [$DEB_FILE] already exist; skipping."
  fi
done # end for loop


# ------------------------------------------
# SCAN FILE SYSTEM FOR [BETA] ARCHIVES
# ------------------------------------------

# iterate over archive files
for ARCHIVE_FILE in $ARCHIVE_DIRECTORY/beta/$ARCHIVE_FILE_FILTER; do

  # extract version from filename
  VERSION="${ARCHIVE_FILE}"
  VERSION="${VERSION#*_}" # remove characters before and including first underscore
  VERSION="${VERSION%${ARCHIVE_FILE_FILTER_EXTENSION}*}" # remove file extension suffix
  VERSION="${VERSION//_/.}"  # replace underscores with dots in version string

  # build debian package file name
  DEB_FILENAME="${DEB_FILE_PREFIX}${VERSION}-beta"
  DEB_FILE="${DEB_FILENAME}${DEB_FILE_EXTENSION}"

  echo "Discovered version [$VERSION] from [$ARCHIVE_FILE]; searching for [$DEB_FILE]"

  if [[ ! -e $DEB_FILE ]]; then
    echo "[+] Debian package [$DEB_FILE] does not exist; building it now ..."
    buildDebianPackage $VERSION $ARCHIVE_FILE $DEB_FILE $DEB_FILENAME
  else
    echo "[-] Debian package [$DEB_FILE] already exist; skipping."
  fi
done # end for loop

# ------------------------------------------
# FINISHED
# ------------------------------------------
exit 0 # all done; return success value

# docker run --rm --volume $(pwd):/build pi4j/pi4j-builder-repo:latest .build/build-deb-package.sh
