set TCLHOME=w:/TCL/TCL8.3/tcl8.3.2
set TCLBIN=%TCLHOME%/win/Release
set WOKHOME=.
set PATH=D%TCLBIN%;%WOKHOME%/lib/wnt;%PATH%

rem If Not Defined TCL_RCFILE set TCL_RCFILE=%WOKHOME%\.tclshrc


%TCLBIN%/tclsh.exe

