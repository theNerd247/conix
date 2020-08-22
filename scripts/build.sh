#!/usr/bin/env bash

set -ex

# Pull down the branch originating the PR or branch pushed to
# This makes it so we can create fixup commits
if [[ "$TRAVIS_PULL_REQUEST" -eq "false" ]]; then
  echo "using travis branch"
  branch=$TRAVIS_BRANCH
else
  echo "using travis PR branch";
  branch="pull/$TRAVIS_PULL_REQUEST/merge"
fi

git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch origin $branch
git checkout -t "origin/$branch"

./scripts/mkDocs.sh 
