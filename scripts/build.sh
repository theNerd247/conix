#!/usr/bin/env bash

set -ex

# Pull down the branch originating the PR or branch pushed to
# This makes it so we can create fixup commits
if [[ -n "$TRAVIS_PULL_REQUEST" ]]; then
  branch=$TRAVIS_PULL_REQUEST_BRANCH
else
  branch=$TRAVIS_BRANCH
fi

git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch origin "$branch"

git checkout $branch

./scripts/mkDocs.sh 

# git add ./docs.md ./readme.md
# 
# git commit -m "updates docs and readme"
# git push https://theNerd247:${GITHUB_TOKEN}@github.com/theNerd247/conix.git "$branch"
