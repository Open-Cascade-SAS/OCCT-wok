@echo off

rem This file setup WOK environment (calls 'wok_env.bat' script)
rem and launches the TCL shell bound to WOK.

call "%~dp0wok_env.bat"
set "aPathBack=%CD%"
cd "%WOK_ROOTADMDIR%"
"%TCLBIN%/tclsh85.exe"
cd "%aPathBack%"
