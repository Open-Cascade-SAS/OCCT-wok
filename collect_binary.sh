#!/bin/bash

# $1 - debug OR release
# $2 - compiler name
# $3 - related package name

installRelatePath="package"
if [ "$3" != "" ]; then
  installRelatePath=$3
fi

if [ "$1" == "" -o "$2" == "" ]; then
  echo "Some arguments are empty. Please try again. For example,"
  echo "$0 release make installDirRelatedPath"
  exit 1
fi

# # Setup environment
source ./env.sh "$1"

source ./collect_binary_without_libs.sh $installRelatePath

mkdir -p $installRelatePath/3rdparty/lin${ARCH}/codegen
mkdir -p $installRelatePath/3rdparty/lin${ARCH}/tcltk

# occt libs checking
preOCCTLibPath="${CASROOT}/lin${ARCH}/${cmdArg2}/lib${CASDEB}"
if [ -e "$preOCCTLibPath/libTKernel.so" ]; then
  cp -f "$preOCCTLibPath/libTKernel.so" $installRelatePath/lib/lin/
else
  echo "$preOCCTLibPath/libTKernel.so does not exist"
fi
if [ -e "$preOCCTLibPath/libTKAdvTools.so" ]; then
  cp -f "$preOCCTLibPath/libTKAdvTools.so" $installRelatePath/lib/lin/
else
  echo "$preOCCTLibPath/libTKAdvTools.so does not exist"
fi

#wok libs checking
preWOKLibPath="./lin${ARCH}/${cmdArg2}/lib${CASDEB}"
if [ -d "$preWOKLibPath" ]; then
  cp -f -R "$preWOKLibPath/*" $installRelatePath/lib/lin/
else
  echo "$preWOKLibPath folder DOES NOT exist! "
fi