@echo off
Setlocal EnableDelayedExpansion

set COPYCMD=/Y

rem %1 - vcver
rem %2 - arch
rem %3 - debug&release
rem %4 - related package name

set "installPath=package"

set configFile=collect_binary.cfg
if exist %configFile% (
  for /f "delims=" %%x in (%configFile%) do (set "%%x")
)

if not "%1" == "" set "cmdArg1=%1"
if not "%2" == "" set "cmdArg2=%2"
if not "%3" == "" set "cmdArg3=%3"
if not "%4" == "" set "installPath=%4"

rem if command line is empty and config file is not exist
if "%cmdArg1%" == "" goto :eofWithEcho 
if "%cmdArg2%" == "" goto :eofWithEcho 
if "%cmdArg3%" == "" goto :eofWithEcho 

goto :GoOn

:eofWithEcho 
echo Some arguments are empty. Please try again. For example,
echo %0 vc10 64 release installDirRelatedPath
goto :eof

:GoOn

echo.
echo "args are: %cmdArg1% %cmdArg2% %cmdArg3% %installPath%
echo.

rem Setup environment
call "%~dp0env.bat" %cmdArg1% %cmdArg2% %cmdArg3%

if "%ARCH%" == "32" (
  set "xBit=x86"
) else (
  if "%VCVER%" == "vc9" (
    set "xBit=amd64"
  ) else if "%VCVER%" == "vc10" (
    set "xBit=x64"
  ) else if "%VCVER%" == "vc11" (
    set "xBit=x64"
  ) 
)

set "TCL_LIB_PATH="
for %%a IN (%searchLibString%) DO (
  if not "%%a" == "" (
    set "line=%%a"
    if not !line!==!line:Tcl=! (
      set "TCL_LIB_PATH=!line!"
      goto exitfor
    )
    
    if not !line!==!line:TCL=! (
      set "TCL_LIB_PATH=!line!"
      goto exitfor
    )
    
    if not !line!==!line:tcl=! (
      set "TCL_LIB_PATH=!line!"
      goto exitfor
    )
  )
)
:exitfor

if "%VCVER%" == "vc8" (
  set "VSDir=%VS80COMNTOOLS%"
  set "msvcXNum=80"
  
) else if "%VCVER%" == "vc9" (
  set "VSDir=%VS90COMNTOOLS%"
  set "msvcXNum=90"
  
) else if "%VCVER%" == "vc10" (
  set "VSDir=%VS100COMNTOOLS%"
  set "msvcXNum=100"
  
) else if "%VCVER%" == "vc11" (
  set "VSDir=%VS110COMNTOOLS%"
  set "msvcXNum=110"
  
) else (
  echo Error: wrong VS identifier
  exit /B
)

set "doNotCopyForeignFileList="

if exist "%CASROOT%\win%ARCH%\%VCVER%\bin%CASDEB%" (
  set "preOCCDLLPath=win%ARCH%\%VCVER%\bin%CASDEB%"
) else if exist "%CASROOT%\wnt\bin%CASDEB%" (
  echo.
  echo "%CASROOT%\wnt\bin%CASDEB% doesn't exist."
  echo "%CASROOT%\wnt\bin%CASDEB% folder has been chosen"
  echo.
  set "preOCCDLLPath=wnt\bin%CASDEB%"
) else (
  echo.
  echo "OCC dll folders (%CASROOT%\win%ARCH%\%VCVER%\bin%CASDEB% and %CASROOT%\wnt\bin%CASDEB%) don't exist"
  echo "Please enter the correct paths"
  echo.
  goto :eof
)

xcopy "%CASROOT%\%preOCCDLLPath%\TKernel.dll" "%installPath%\lib\wnt\"
if not %errorlevel%. == 0. (set "doNotCopyForeignFileList=%doNotCopyForeignFileList%;TKernel.dll")

xcopy "%VSDir%..\..\VC\redist\%xBit%\Microsoft.%VCVER%0.CRT\msvcp%msvcXNum%.dll" "%installPath%\lib\wnt\"
if not %errorlevel%. == 0. (set "doNotCopyForeignFileList=%doNotCopyForeignFileList%;msvcp%msvcXNum%.dll")

xcopy "%VSDir%..\..\VC\redist\%xBit%\Microsoft.%VCVER%0.CRT\msvcr%msvcXNum%.dll" "%installPath%\lib\wnt\"
if not %errorlevel%. == 0. (set "doNotCopyForeignFileList=%doNotCopyForeignFileList%;msvcr%msvcXNum%.dll")

if exist "%~dp0win%ARCH%\%VCVER%\bin%CASDEB%" (
  set "preDLLPath=win%ARCH%\%VCVER%\bin%CASDEB%"
) else if exist "%~dp0wnt\bin%CASDEB%" (
  echo.
  echo "%~dp0win%ARCH%\%VCVER%\bin%CASDEB% doesn't exist."
  echo "%~dp0wnt\bin%CASDEB% folder has been chosen"
  echo.
  set "preDLLPath=wnt\bin%CASDEB%"
) else (
  echo.
  echo "WOK dll folders (%~dp0win%ARCH%\%VCVER%\bin%CASDEB% ; %~dp0wnt\bin%CASDEB%) don't exist."
  echo "Please enter the correct paths"
  echo.
  goto :eof
)

xcopy "%~dp0%preDLLPath%\*.dll" "%installPath%\lib\wnt\"
if not %errorlevel%. == 0. (set "doNotCopyForeignFileList=bin *.dll")

call "%~dp0collect_binary_without_libs.bat" %installPath%

echo.
echo =========end operation===========
if not "%doNotCopyForeignFileList%" == "" (
  echo "%doNotCopyForeignFileList% files has not been copied"
)
echo.
