#!/usr/bin/env bash

docs=$(nix-build ./documentation.nix --show-trace)
cp $docs/*.md ./.
