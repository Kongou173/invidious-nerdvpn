#!/usr/bin/env bash

cd build

git checkout .
git restore .
git reset
git clean -fd
