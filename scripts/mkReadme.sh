#!/usr/bin/env bash

readme=$(nix-build ./readme --show-trace)
cp $readme/readme.md ./.
