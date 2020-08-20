#!/usr/bin/env bash

set -ex

# Pull down the branch originating the PR or branch pushed to
# This makes it so we can create fixup commits
if $TRAVIS_PULL_REQUEST; then
  branch=$TRAVIS_PULL_REQUEST_BRANCH
else
  branch=$TRAVIS_BRANCH
fi

git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch "$branch"
git checkout -t origin/branch
git config user.email "travis@travis.org"
git config user.name "travis"

./scripts/mkGitNix.sh

if git status --porcelain | grep "M git.nix"; then 
  git add ./git.nix
  git commit -m "updates git.nix"
  git push https://theNerd247:${GITHUB_TOKEN}@github.com/theNerd247/conix.git "$branch"
fi

./scripts/mkDocs.sh 

if [[ $(git status --porcelain | grep "M docs.md") || $(git status --porcelain | grep "M readme.md") ]]; then 
  git add ./docs.md ./readme.md
  git commit --allow-empty -m "updates docs and readme"
  git push https://theNerd247:${GITHUB_TOKEN}@github.com/theNerd247/conix.git "$branch"
fi
