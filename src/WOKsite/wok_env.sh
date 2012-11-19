#!/bin/bash

# This file setup WOK environment.
# Notice that usually you shouldn't modify this file.
# To override some settings create/edit 'custom.sh' file
# within the same directory.

# go to the script directory
aScriptPath=${BASH_SOURCE%/*}; if [ -d "${aScriptPath}" ]; then cd "$aScriptPath"; fi; aScriptPath="$PWD";

# ----- Reset environment variables -----
if [ "$PATH_BACK" == "" ]; then
  export PATH_BACK="$PATH";
  export LD_PATH_BACK="$LD_LIBRARY_PATH";
  export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH";
fi

export TCLSH_EXE="tclsh8.5"
export PATH="$PATH_BACK";
export LD_LIBRARY_PATH="$LD_PATH_BACK";
export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH";
export CPATH="";
export LIBRARY_PATH="";
export HAVE_TBB="false";
export HAVE_FREEIMAGE="false";
export HAVE_GL2PS="false";
export PRODUCTS_DEFINES="";

# ----- Set local settings -----
if [ -e "${aScriptPath}/custom.sh" ]; then
  source "${aScriptPath}/custom.sh"
fi

if [ "$HAVE_TBB"       == "true" ]; then
  export PRODUCTS_DEFINES="$PRODUCTS_DEFINES -DHAVE_TBB";
fi
if [ "$HAVE_GL2PS"     == "true" ]; then
  export PRODUCTS_DEFINES="$PRODUCTS_DEFINES -DHAVE_GL2PS";
fi
if [ "$HAVE_FREEIMAGE" == "true" ]; then
  export PRODUCTS_DEFINES="$PRODUCTS_DEFINES -DHAVE_FREEIMAGE";
fi

# ----- Setup Environment Variables -----
anArch=`uname -m`
if [ "$anArch" != "x86_64" ] && [ "$anArch" != "ia64" ]; then
  export ARCH="32";
else
  export ARCH="64";
fi

aSystem=`uname -s`
if [ "$aSystem" == "Darwin" ]; then
  export WOKSTATION="mac";
  export ARCH="64";
else
  export WOKSTATION="lin";
fi

# ----- Define WOK root -----
export WOKHOME="${aScriptPath}/..";
if [ "$HOME" != "$WOKHOME/home" ]; then
  # to pass X security checks
  ln -s -f "$HOME/.Xauthority" "$WOKHOME/home/.Xauthority"
  export HOME="$WOKHOME/home";
fi

# ----- 3rd-parties root -----
if [ "$PRODUCTS_PATH" == "" ]; then
  export PRODUCTS_PATH="${WOKHOME}/3rdparty/${WOKSTATION}${ARCH}"
fi

# ----- Setup Environment Variables for WOK -----
export WOK_ROOTADMDIR="$WOKHOME/wok_entities";
export WOK_LIBRARY="$WOKHOME/lib";
export WOK_LIBPATH="$WOK_LIBRARY/$WOKSTATION";
export WOKSITE="$WOKHOME/site";
export WOK_SESSIONID="$HOME";

# ----- Setup Environment Variables PATH and LD_LIBRARY_PATH -----
# Linux and so on
aTail=":${LD_LIBRARY_PATH}"
if [ "$LD_LIBRARY_PATH" == "" ]; then aTail=""; fi
export LD_LIBRARY_PATH="${WOK_LIBPATH}${aTail}"

# Mac OS X
aTail=":${DYLD_LIBRARY_PATH}"
if [ "$DYLD_LIBRARY_PATH" == "" ]; then aTail=""; fi
export DYLD_LIBRARY_PATH="${WOK_LIBPATH}${aTail}"
export WOK_LIBPATH="${WOK_LIBRARY}:${WOK_LIBPATH}"

export PATH="$WOK_LIBPATH:$PATH"
if [ "$WOKSTATION" == "lin" ]; then
  # always use 32-bit binaries
  export BISON_SIMPLE="$WOKHOME/3rdparty/lin32/codegen/bison.simple"
  export PATH="${WOKHOME}/3rdparty/lin32/tcltk/bin:${WOKHOME}/3rdparty/lin32/codegen:${PATH}"
  export LD_LIBRARY_PATH="${WOKHOME}/3rdparty/lin32/tcltk/lib:${LD_LIBRARY_PATH}"
else
  export BISON_SIMPLE="$WOKHOME/3rdparty/${WOKSTATION}${ARCH}/codegen/bison.simple"
  export PATH="${WOKHOME}/3rdparty/${WOKSTATION}${ARCH}/codegen:${PATH}"
fi
