#!/usr/bin/env bash

docs=$(nix-build ./documentation.nix --show-trace)
cp --no-preserve=mode $docs/readme.md ./readme.md
cp --no-preserve=mode -r $docs/docs ./docs
