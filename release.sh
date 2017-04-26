#!/bin/bash

VERSION_NUMBER="$1"
if [ -z $VERSION_NUMBER ]; then
  printf "USAGE: \r\n./release <version-number>\n";
  exit
else

  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Version tag already exist, exiting...\n"
      exit
  fi

  printf "Releasing version $VERSION_NUMBER\n";
fi

printf "#define MOBILEENGAGE_SDK_VERSION @\"$VERSION_NUMBER\"" > MobileEngage/MobileEngageVersion.h

TEMPLATE="`cat MobileEngageSDK.podspec.template`"
PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
printf "$PODSPEC" > MobileEngageSDK.podspec

git add MobileEngage/MobileEngageVersion.h
git add MobileEngageSDK.podspec
git commit -m "chore(release): version set to $VERSION_NUMBER"
git tag -a "$VERSION_NUMBER" -m "$VERSION_NUMBER"

git push
git push --tags

pod spec lint
pod trunk push MobileEngageSDK.podspec

printf "[$VERSION_NUMBER] released, go eat some cookies."
