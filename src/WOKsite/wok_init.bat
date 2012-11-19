@echo off

rem This file setup WOK environment  (calls 'wok_env.bat' script)
rem and perform default initialization according to current environment.
rem As a result empty :LOC:dev will be created (if not yet exists).

call "%~dp0wok_env.bat"
set "aPathBack=%CD%"
cd "%WOK_ROOTADMDIR%"
"%TCLBIN%/tclsh85.exe" < "%WOKHOME%/site/CreateFactory.tcl"
cd "%aPathBack%"
