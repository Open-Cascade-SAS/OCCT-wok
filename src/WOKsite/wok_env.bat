@echo off

rem This file setup WOK environment.
rem Notice that usually you shouldn't modify this file.
rem To override some settings create/edit 'custom.bat' file
rem within the same directory.

rem ----- Reset environment variables -----
if ["%PATH_BACK%"] == [""] set "PATH_BACK=%PATH%"
rem set "PATH=%PATH_BACK%"
set "VCVER=vc8"
set "ARCH=32"
set "PATH=%SYSTEMROOT%\system32;%SYSTEMROOT%"
set "INCLUDE="
set "LIB="
set "DevEnvDir="
set "HAVE_TBB=false"
set "HAVE_FREEIMAGE=false"
set "HAVE_GL2PS=false"
set "VCVARS="

rem ----- Set local settings (M$ Visual Studio compilers etc.) -----
if exist "%~dp0custom.bat" (
  call "%~dp0custom.bat" %1 %2 %3 %4 %5
)

set "PRODUCTS_DEFINES="
if ["%HAVE_TBB%"]       == ["true"] set "PRODUCTS_DEFINES=%PRODUCTS_DEFINES% -DHAVE_TBB"
if ["%HAVE_GL2PS%"]     == ["true"] set "PRODUCTS_DEFINES=%PRODUCTS_DEFINES% -DHAVE_GL2PS"
if ["%HAVE_FREEIMAGE%"] == ["true"] set "PRODUCTS_DEFINES=%PRODUCTS_DEFINES% -DHAVE_FREEIMAGE"

rem ----- Setup Environment Variables for M$ Visual Studio compilers -----
if ["%ARCH%"] == ["32"] set VCARCH=x86
if ["%ARCH%"] == ["64"] set VCARCH=amd64

if not ["%VCVARS%"] == [""] (
  call "%VCVARS%" %VCARCH%
) else if ["%DevEnvDir%"] == [""] if not ["%VS100COMNTOOLS%"] == [""] (
  call "%VS100COMNTOOLS%..\..\VC\vcvarsall.bat" %VCARCH%
  set VCVER=vc10
) else if ["%DevEnvDir%"] == [""] if not ["%VS90COMNTOOLS%"] == [""] (
  call "%VS90COMNTOOLS%..\..\VC\vcvarsall.bat" %VCARCH%
  set VCVER=vc9
) else if ["%DevEnvDir%"] == [""] if not ["%VS80COMNTOOLS%"] == [""] (
  call "%VS80COMNTOOLS%..\..\VC\vcvarsall.bat" %VCARCH%
  set VCVER=vc8
)

rem ----- 3rd-parties root -----
if ["%PRODUCTS_PATH%"]  == [""] set PRODUCTS_PATH=G:/occt-3rdparty/occt650products/

rem ----- Define WOK root -----
set "WOKHOME=%~dp0.."
rem Stupid TCL needs Unish paths
set "WOKHOME=%WOKHOME:\=/%"
set "HOME=%WOKHOME%/home"

rem ----- Setup Environment Variables for WOK -----
set "WOK_ROOTADMDIR=%WOKHOME%/wok_entities"
set "WOKSTATION=wnt"
set "WOK_LIBRARY=%WOKHOME%/lib"
set "WOK_LIBPATH=%WOK_LIBRARY%;%WOK_LIBRARY%/%WOKSTATION%"
set "WOKSITE=%WOKHOME%/site"
set "WOK_SESSIONID=%HOME%"

rem ----- Setup Environment Variables for TCL/TK -----
set "TCLHOME=%WOKHOME%/3rdparty/win32/tcltk"
set "TCLBIN=%TCLHOME%/bin"
set "TCLLIB=%TCLHOME%/lib"
set "TCL_LIBRARY=%TCLLIB%/tcl8.5"
set "TK_LIBRARY=%TCLLIB%/tk8.5"
rem set "TCLX_LIBRARY=%TCLLIB%/teapot/package/win32-ix86/lib/tclx8.4"
rem set "TCLLIBPATH=%TCLBIN% %TCLLIB% %TCL_LIBRARY% %TK_LIBRARY% %TCLX_LIBRARY%"
set "TCLLIBPATH=%TCLBIN% %TCLLIB% %TCL_LIBRARY% %TK_LIBRARY%"

rem ----- Setup additional variables -----
rem set "TCL_RCFILE=%HOME%/tclshrc.tcl"
set "BISON_SIMPLE=%WOKHOME%/3rdparty/win32/codegen/bison.simple"

rem ----- Setup Environment Variable PATH -----
set "PATH=%WOK_LIBPATH%;%WOKHOME%/3rdparty/win32/codegen;%WOKHOME%/3rdparty/win32/utils;%TCLHOME%/bin;%TCLHOME%/lib;%WOKHOME%/3rdparty/win32/perl/bin;%PATH%"
