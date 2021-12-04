#!/bin/bash
set -e

CODENAME=v4
DISTRIBUTION=dists/${CODENAME}

# define the file filters used to determine all releases and snapshots for version 2.x
FILE_FILTER_PREFIX="homeseer-4\.[0-9]*"
RELEASE_FILE_FILTER="${FILE_FILTER_PREFIX}-release.deb"
TESTING_FILE_FILTER="${FILE_FILTER_PREFIX}-beta.deb"

# clean and create working directories
rm -R {${DISTRIBUTION},tmp} || true
mkdir -p ${DISTRIBUTION}/{stable,testing}/binary-all
mkdir -p tmp

#----------------------------------------
# [V4] DISTRIBUTION [STABLE] COMPONENT
#----------------------------------------

# define constant for [STABLE] component
COMPONENT=stable

echo "--------------------------------------------"
echo "BUILDING HOMESEER.SH APT REPOSITORY FOR:   "
echo "   > ${DISTRIBUTION}/${COMPONENT}"
echo "--------------------------------------------"
echo "THE FOLLOWING FILES WILL BE INCLUDED:"
ls ${RELEASE_FILE_FILTER} || true
echo "--------------------------------------------"

# copy all HOMESEER V4.x release|stable distribution packages (.deb) to temporary working directory
cp ${RELEASE_FILE_FILTER} tmp || true

# create 'Package' file for the [V4] distribution [STABLE] component
dpkg-scanpackages --multiversion --extra-override .build/homeseer.override tmp > ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# remove "tmp/" root path from "Filename" in Packages file
sed -i 's/^Filename: tmp\//Filename: /g' ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# create compressed Packages file for the [V4] distribution [STABLE] component
gzip -k -f ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# create Release files for the [V4] distribution [STABLE] component
apt-ftparchive release ${DISTRIBUTION}/${COMPONENT}/binary-all > ${DISTRIBUTION}/${COMPONENT}/binary-all/Release


#----------------------------------------
# [V4] DISTRIBUTION [TESTING] COMPONENT
#----------------------------------------

# define constant for [TESTING] component
COMPONENT=testing

# clean temporary working directory
rm -R tmp/* || true

echo "--------------------------------------------"
echo "BUILDING HOMESEER.SH APT REPOSITORY FOR:   "
echo "   > ${DISTRIBUTION}/${COMPONENT}"
echo "--------------------------------------------"
echo "THE FOLLOWING FILES WILL BE INCLUDED:"
ls ${TESTING_FILE_FILTER} || true
echo "------------------------------------"

# copy all HOMESEER V4.x beta|release-candidate distribution packages (.deb) to temporary working directory
cp ${TESTING_FILE_FILTER} tmp || true

# create 'Package' file for the [V4] distribution [TESTING] component
dpkg-scanpackages --multiversion --extra-override .build/homeseer.override tmp > ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# remove "tmp/" root path from "Filename" in Packages file
sed -i 's/^Filename: tmp\//Filename: /g' ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# create compressed Packages file for the [V4] distribution [TESTING] component
gzip -k -f ${DISTRIBUTION}/${COMPONENT}/binary-all/Packages

# create Release files for the [V4] distribution [TESTING] component
apt-ftparchive release ${DISTRIBUTION}/${COMPONENT}/binary-all > ${DISTRIBUTION}/${COMPONENT}/binary-all/Release


#----------------------------------------
# CREATE AND SIGN [V4] RELEASE
#----------------------------------------

# create Release files for the [V4] distribution
apt-ftparchive \
  -o APT::FTPArchive::Release::Origin="https://homeseer.sh/download" \
  -o APT::FTPArchive::Release::Label="Homeseer Linux Server" \
  -o APT::FTPArchive::Release::Suite="${CODENAME}" \
  -o APT::FTPArchive::Release::Codename="${CODENAME}" \
  -o APT::FTPArchive::Release::Architectures="all" \
  -o APT::FTPArchive::Release::Components="stable" \
  release ${DISTRIBUTION} > ${DISTRIBUTION}/Release

# import PGP private key from file
gpg --import homeseer.key

# sign Release files for the [V4] distribution
gpg --default-key "team@homeseer.sh" -abs -o - ${DISTRIBUTION}/Release > ${DISTRIBUTION}/Release.gpg
gpg --default-key "team@homeseer.sh" --clearsign -o - ${DISTRIBUTION}/Release > ${DISTRIBUTION}/InRelease

# clean and remove temporary working directory
rm -R tmp
