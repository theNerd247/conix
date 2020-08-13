#!/usr/bin/env bash

function mkDesign {
  design=$(nix-build ./design --show-trace)
  cp $design/design.md ./design.md
}

./scripts/mkGitHeadHash && mkDesign
