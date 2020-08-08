#!/usr/bin/env bash

design=$(nix-build ./design --show-trace)
cp $design/design.md ./design.md
