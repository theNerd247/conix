#!/usr/bin/env bash

docs=$(nix-build -E "(import <nixpkgs> { overlays = import ./. {}; }).conix.docs" --show-trace)
cp --no-preserve=mode $docs/readme.* ./.
