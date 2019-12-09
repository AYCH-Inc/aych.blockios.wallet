#!/usr/bin/env bash

set -ue

if ! command -v carthage; then
    brew install carthage 
fi

# These dependencies are needed to build `libwally-core`
brew install libtool pkg-config autoconf automake gnu-sed