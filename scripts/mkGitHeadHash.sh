#!/usr/bin/env bash

nix-shell -p git --run "git rev-parse HEAD > ./gitHeadHash"
