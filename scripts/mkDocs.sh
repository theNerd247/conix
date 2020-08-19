#!/usr/bin/env bash

docs=$(nix-build ./documentation.nix --show-trace)
cp --no-preserve=mode $docs/*.md ./.
