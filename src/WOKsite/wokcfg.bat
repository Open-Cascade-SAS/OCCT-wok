if "%1" == "" goto run
set option=%1
rem ***
rem *** Set basic Wok environment with adequate defaulted value.
rem ***
if not %1%==configure goto next1
%2\lib\wnt\sed.exe -e s@TOSUBSTITUTE_WOKHOME@"%2"@g -e s@TOSUBSTITUTE_FACTORYPROC@"%3"@g %2/site/wokcfg.bat > %4
%2\lib\wnt\sed.exe -e s@TOSUBSTITUTE@"%3"@g %2/site/WOKSESSION.edl > %3/WOKSESSION.edl
goto end
:next1
rem ***
rem *** Set directory where wok creates entities.
rem ***
if not %1%==setup goto next2
%2\lib\wnt\sed.exe -e s@/dp_xx/@"%3"@g %2/site/DEFAULT.edl > TOSUBSTITUTE_FACTORYPROC/DEFAULT.edl
goto end
:next2
rem ***
rem *** Modify the TCLHOME variable according to you installation of Tcl
rem *** Modify the TIX_LIBRARY variable according to you installation of Tix
:run
set TCLHOME=D:\DevTools\Tcltk
set TIX_LIBRARY=D:/DevTools/Tcltk/lib/tix4.1
rem set WOK_SESSIONID=W:\home\me
set WOKHOME=TOSUBSTITUTE_WOKHOME
set WOK_ROOTADMDIR=TOSUBSTITUTE_FACTORYPROC
set WOK_LIBRARY=%WOKHOME%/lib
set WOKSTATION=wnt
set path=%path%;%TCLHOME%\bin;
set path=%path%%WOKHOME%/lib/wnt;
set WOK_LIBPATH=%WOK_LIBRARY%;%WOK_LIBRARY%/wnt
set TCLLIBPATH=%WOK_LIBRARY%/wnt %WOK_LIBRARY%
set TCL_RCFILE=%WOKHOME%\site\tclshrc_Wok
%TCLHOME%/bin/ntsh.exe
:end

