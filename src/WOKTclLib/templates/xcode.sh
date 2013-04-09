#!/bin/bash

export TARGET="xcd"

source ./env.sh "$TARGET" "$1"

open -a Xcode ./adm/mac/xcd/OCCT.xcworkspace
