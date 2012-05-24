#!/bin/bash

# This file setup WOK environment  (calls 'wok_env.sh' script)
# and perform default initialization according to current environment.
# As a result empty :LOC:dev will be created (if not yet exists).

# go to the script directory
aScriptPath=${BASH_SOURCE%/*}; if [ -d "${aScriptPath}" ]; then cd "$aScriptPath"; fi; aScriptPath="$PWD";

source "${aScriptPath}/wok_env.sh"

# ----- Create default Factory :Kas:dev -----
cd "$WOK_ROOTADMDIR"
$TCLSH_EXE < "$WOKHOME/site/CreateFactory.tcl"
