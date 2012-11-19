@echo off

rem This file setup WOK environment (calls 'wok_env.bat' script)
rem and launches the Emacs bound to WOK.
rem Press Alt+x in emacs and enter 'woksh' to launch the WOK shell.

call "%~dp0wok_env.bat"
set "aPathBack=%CD%"
cd "%WOK_ROOTADMDIR%"
call "%WOKHOME%\3rdparty\win32\Emacs\bin\runemacs.exe" -fs
cd "%aPathBack%"
