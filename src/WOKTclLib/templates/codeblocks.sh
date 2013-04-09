#!/bin/bash

export TARGET="cbp"

source ./env.sh "$TARGET" "$1"

/Applications/CodeBlocks.app/Contents/MacOS/CodeBlocks ./adm/mac/cbp/OCCT.workspace
