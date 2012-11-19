#!/bin/bash

# This file setup WOK environment (calls 'wok_env.sh' script)
# and launches the Emacs bound to WOK.
# Press Alt+x in emacs and enter 'woksh' to launch the WOK shell.

# go to the script directory
aScriptPath=${BASH_SOURCE%/*}; if [ -d "${aScriptPath}" ]; then cd "$aScriptPath"; fi; aScriptPath="$PWD";

source "${aScriptPath}/wok_env.sh"

cd "$WOK_ROOTADMDIR"
emacs
