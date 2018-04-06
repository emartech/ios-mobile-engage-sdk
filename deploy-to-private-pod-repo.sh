#!/bin/bash

function deploy {
  VERSION_NUMBER=$(git describe --tags --abbrev=0 | perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3+1).$4/e;')
  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Version tag already exist, exiting...\n"
      exit
  fi

  printf "Deploying version $VERSION_NUMBER to private cocoapods...\n";

  TEMPLATE="`cat MobileEngageSDK.podspec.template`"
  PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
  printf "$PODSPEC" > MobileEngageSDK.podspec

  git tag -a "$VERSION_NUMBER" -m "$VERSION_NUMBER"

  git push --tags

  pod repo push emapod MobileEngageSDK.podspec --allow-warnings

  printf "[$VERSION_NUMBER] deployed to private cocoapod."
}

deploy
