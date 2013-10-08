#!/bin/bash

export TARGET="cbp"

source ./env.sh "$TARGET" "$1"

if [ -e "/Applications/CodeBlocks.app/Contents/MacOS/CodeBlocks" ]; then
  /Applications/CodeBlocks.app/Contents/MacOS/CodeBlocks ./adm/$WOKSTATION/cbp/OCCT.workspace
else
  codeblocks ./adm/$WOKSTATION/cbp/OCCT.workspace
fi
