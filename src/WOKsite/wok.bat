set TCLHOME=%CASROOT%/../3rdparty/win32/tcltk
set TCLBIN=%TCLHOME%/bin
set WOKHOME=%CASROOT%/../wok
set PATH=%TCLBIN%;%WOKHOME%/lib/wnt;%PATH%
set TCL_RCFILE=%WOKHOME%/site/tclshrc.tcl
set WOK_ROOTADMDIR=%WOKHOME%/wok_entities
set HOME=%WOKHOME%/site
set INIT=%WOKHOME%/lib/wnt
cd %WOK_ROOTADMDIR%
%TCLBIN%/tclsh.exe
