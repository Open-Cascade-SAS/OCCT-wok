#!/bin/bash

# This file setup WOK environment (calls 'wok_env.sh' script)
# and launches the TCL shell bound to WOK.

# go to the script directory
aScriptPath=${BASH_SOURCE%/*}; if [ -d "${aScriptPath}" ]; then cd "$aScriptPath"; fi; aScriptPath="$PWD";

source "${aScriptPath}/wok_env.sh"

cd "$WOK_ROOTADMDIR"
$TCLSH_EXE "${aScriptPath}/wok_depsgui.tcl"
