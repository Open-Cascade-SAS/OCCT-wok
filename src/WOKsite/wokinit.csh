#!/bin/csh -f
#

if ( $?CASROOT ) then
    unsetenv CASROOT
endif

if ( $?TCLHOME ) then
    unsetenv TCLHOME
endif

if ( $?TCLLIBPATH ) then
    unsetenv TCLLIBPATH
endif

if ( $?HOME ) then
    unsetenv HOME
endif

if ( $?WOKHOME ) then
    unsetenv WOKHOME
endif

if ( $?WOK_LIBRARY ) then
    unsetenv WOK_LIBRARY
endif

if ( $?WOK_LIBPATH ) then
    unsetenv WOK_LIBPATH
endif

if ( $?WOK_ROOTADMDIR ) then
    unsetenv WOK_ROOTADMDIR
endif

if ( $?FACTORYHOME ) then
    unsetenv FACTORYHOME
endif

if ( $?ATLIST ) then
    unsetenv ATLIST
endif

unsetenv LD_LIBRARY_PATH
if ( $?LD_LIBRARY_PATH ) then
    unsetenv LD_LIBRARY_PATH
endif

setenv CASROOT /dn06/cascade/tst/ros

set OS_NAME=`uname`
set OS_PLATFORM=""
if ( $OS_NAME == "SunOS" ) then
   set OS_PLATFORM="sun"
else if ( $OS_NAME == "Linux" ) then
   set OS_PLATFORM="lin"
endif

setenv WOKHOME ${CASROOT}/../wok
setenv HOME ${WOKHOME}/site
setenv WOK_LIBPATH ${WOKHOME}/lib/${OS_PLATFORM}

setenv WOK_ROOTADMDIR ${WOKHOME}/wok_entities
setenv WOK_SESSIONID ${HOME}

setenv TCLHOME ${CASROOT}/../3rdparty/${OS_NAME}/tcltk
setenv TCLLIBPATH "${TCLHOME}/lib:${WOK_LIBPATH}"

set TCLLIB=${TCLHOME}/lib
set TCLBIN=${TCLHOME}/bin

setenv LD_LIBRARY_PATH "/usr/lib:/usr/X11R6/lib:/lib:${TCLLIB}:${WOKHOME}/lib/:${WOKHOME}/lib/${OS_PLATFORM}"
setenv path "/usr/bin /bin /usr/bin /sbin /usr/sbin /usr/local/bin /usr/local/sbin /usr/X11R6/bin /etc"
setenv PATH "/usr/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/etc"

echo ${LD_LIBRARY_PATH}
env | grep -i wok
env | grep -i tcl

cd ${WOK_ROOTADMDIR}

#printf "source ${WOKHOME}/site/CreateFactory.tcl\nCreateFactory $WOK_ROOTADMDIR OS OCC51 ros $CASROOT\nwokcd OS:OCC51:ros\nexit\n"|${TCLBIN}/tclsh
${TCLBIN}/tclsh < ${WOKHOME}/site/CreateFactory.tcl

