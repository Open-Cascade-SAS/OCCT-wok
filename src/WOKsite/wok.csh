#!/bin/csh -f
#
# Use this file ONLY if you need to launch different version of Wok
# or if you want to adress different Wok entities.
# If you use this file , the 2 first arguments are mandatory.
# 
#
set noglob ; set narg = $#argv 
if ( $narg > 3 || $narg == 1 || $narg == 0 ) then
  echo "Usage : wok.csh wok_home wok_entities [tclhome] "
  echo "        wok_home(required)     is the path of directory for wok shareable (Ex: <root>/lib/sun) "
  echo "        wok_entities(required) is the path of an ATLIST file."
  echo "        tclhome(optional)      is the home directory of a Tcl distribution."
  echo "   "
  exit
endif

if ( $narg == 2 ) then
  set  wokhome=$argv[1]
  setenv WOK_ROOTADMDIR $argv[2]
endif


set TCLHOME=/usr
if ( $narg == 3 ) then
   set wokhome=$argv[1]
   setenv WOK_ROOTADMDIR $argv[2]
   set TCLHOME=$argv[3]
endif


set TCLLIB=${TCLHOME}/lib
set TCLBIN=${TCLHOME}/bin
if ( $?TCLLIBPATH ) then
    unsetenv TCLLIBPATH
endif
if ( ! ($?LD_LIBRARY_PATH) ) then
    setenv LD_LIBRARY_PATH ""
endif
setenv LD_LIBRARY_PATH "${TCLLIB}:${wokhome}:${LD_LIBRARY_PATH}:"
${TCLBIN}/tclsh


