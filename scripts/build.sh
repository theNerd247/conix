#!/usr/bin/env bash

./scripts/mkGitNix.sh

git config user.email "travis@travis.org"
git config user.name "travis"
git add ./git.nix
git commit --allow-empty -m "updates git.nix"
git push https://theNerd247:${GITHUB_TOKEN}@github.com/theNerd247/conix.git HEAD:HEAD

./scripts/mkDocs.sh 

git config user.email "travis@travis.org"
git config user.name "travis"
git add ./docs.md ./readme.md
git commit --allow-empty -m "updates docs and readme"
git push https://theNerd247:${GITHUB_TOKEN}@github.com/theNerd247/conix.git HEAD:HEAD
