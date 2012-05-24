@echo off

rem This file setup WOK environment (calls 'wok_env.bat' script)
rem and launches the TCL shell bound to WOK.

call %~dp0wok_env.bat

%TCLBIN%/tclsh85.exe %~dp0wok_depsgui.tcl
