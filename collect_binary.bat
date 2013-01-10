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

xcopy "%CASROOT%\%preOCCDLLPath%\TKAdvTools.dll" "%installPath%\lib\wnt\"
if not %errorlevel%. == 0. (set "doNotCopyForeignFileList=%doNotCopyForeignFileList%;TKAdvTools.dll")

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

mkdir "%installPath%\wok_entities\"

mkdir "%installPath%\3rdparty\"
mkdir "%installPath%\3rdparty\win32\"
mkdir "%installPath%\3rdparty\win32\codegen\"
mkdir "%installPath%\3rdparty\win32\Emacs\"
mkdir "%installPath%\3rdparty\win32\tcltk\"
mkdir "%installPath%\3rdparty\win32\utils\"


xcopy "src\WOKsite\tclshrc.tcl"    "%installPath%\home\"
xcopy "src\WOKsite\.emacs"    "%installPath%\home\"
xcopy "src\WOKsite\.emacs"    "%installPath%\home\"

xcopy "src\WOKsite\public_el" "%installPath%\site\public_el\" /S
xcopy "custom.bat" "%installPath%\site\"

xcopy "src\CPPJini\CPPJini_General.edl" "%installPath%\lib\"
xcopy "src\CPPJini\CPPJini_Template.edl" "%installPath%\lib\"

xcopy "src\WOKOBJS\OBJS.edl" "%installPath%\lib\"
xcopy "src\WOKOBJS\OBJSSCHEMA.edl" "%installPath%\lib\"

xcopy "src\WOKLibs\pkgIndex.tcl" "%installPath%\lib\"

xcopy "src\TCPPExt\TCPPExt_MethodTemplate.edl" "%installPath%\lib\"

xcopy "src\WOKDeliv\WOKDeliv_DelivExecSource.tcl" "%installPath%\lib\"
xcopy "src\WOKDeliv\WOKDeliv_FRONTALSCRIPT.edl" "%installPath%\lib\"
xcopy "src\WOKDeliv\WOKDeliv_LDSCRIPT.edl" "%installPath%\lib\"

xcopy "src\CSFDBSchema\CSFDBSchema_Template.edl" "%installPath%\lib\"

xcopy "src\WOKUtils\EDL.edl" "%installPath%\lib\"

xcopy "src\CPPIntExt\Engine_Template.edl" "%installPath%\lib\"
xcopy "src\CPPIntExt\Interface_Template.edl" "%installPath%\lib\"

xcopy "src\WOKTclTools\ENV.edl" "%installPath%\lib\"

xcopy "src\WOKEntityDef\FILENAME.edl" "%installPath%\lib\"

xcopy "src\CPPExt\CPPExt_Standard.edl" "%installPath%\lib\"
xcopy "src\CPPExt\CPPExt_Template.edl" "%installPath%\lib\"
xcopy "src\CPPExt\CPPExt_TemplateCSFDB.edl" "%installPath%\lib\"
xcopy "src\CPPExt\CPPExt_TemplateOBJS.edl" "%installPath%\lib\"
xcopy "src\CPPExt\CPPExt_TemplateOBJY.edl" "%installPath%\lib\"


xcopy "src\WOKOrbix\IDLFRONT.edl" "%installPath%\lib\"
xcopy "src\WOKOrbix\ORBIX.edl" "%installPath%\lib\"
xcopy "src\WOKOrbix\WOKOrbix_ClientObjects.tcl" "%installPath%\lib\"
xcopy "src\WOKOrbix\WOKOrbix_ServerObjects.tcl" "%installPath%\lib\"

xcopy "src\WOKEntityDef\WOKEntity.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Factory.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Parcel.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_ParcelUnit.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Unit.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_UnitTypes.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Warehouse.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Workbench.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_WorkbenchUnit.edl" "%installPath%\lib\"
xcopy "src\WOKEntityDef\WOKEntity_Workshop.edl" "%installPath%\lib\"

xcopy "src\WOKStep\WOKStep_frontal.tcl" "%installPath%\lib\"
xcopy "src\WOKStep\WOKStep_JavaCompile.tcl" "%installPath%\lib\"
xcopy "src\WOKStep\WOKStep_JavaHeader.tcl" "%installPath%\lib\"
xcopy "src\WOKStep\WOKStep_LibRename.tcl" "%installPath%\lib\"
xcopy "src\WOKStep\WOKStep_ManifestEmbed.tcl" "%installPath%\lib\"
xcopy "src\WOKStep\WOKStep_TclLibIdep.tcl" "%installPath%\lib\"


xcopy "src\WOKStepsDef\FRONTAL.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_ccl.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_client.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_client_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_Del.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_delivery.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_documentation.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_engine.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_engine_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_executable.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_executable_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_frontal.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_idl.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_interface.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_interface_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_jini.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_nocdlpack.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_nocdlpack_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_package.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_package_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_resource.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_schema.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_schema_DFLT.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_schema_OBJS.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_schema_OBJY.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_server.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_toolkit.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKSteps_toolkit_wnt.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsDeliv.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsDFLT.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsOBJS.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsOBJY.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsOrbix.edl" "%installPath%\lib\"
xcopy "src\WOKStepsDef\WOKStepsStep.edl" "%installPath%\lib\"

xcopy "src\WOKsite\wok.csh" "%installPath%\site\"
xcopy "src\WOKsite\wokinit.csh" "%installPath%\site\"
xcopy "src\WOKsite\DEFAULT.edl" "%installPath%\site\"
xcopy "src\WOKsite\WOKSESSION.edl" "%installPath%\site\"
xcopy "src\WOKsite\CreateFactory.tcl" "%installPath%\site\"
xcopy "src\WOKsite\interp.tcl" "%installPath%\site\"
xcopy "src\WOKsite\tclshrc.tcl" "%installPath%\site\"
xcopy "src\WOKsite\wok_deps.tcl" "%installPath%\site\"
xcopy "src\WOKsite\wok_depsgui.tcl" "%installPath%\site\"
xcopy "src\WOKsite\wok_tclshrc.tcl" "%installPath%\site\"
xcopy "src\WOKsite\wok.bat" "%installPath%\site\"
xcopy "src\WOKsite\wok_confgui.bat" "%installPath%\site\"
xcopy "src\WOKsite\wok_emacs.bat" "%installPath%\site\"
xcopy "src\WOKsite\wok_env.bat" "%installPath%\site\"
xcopy "src\WOKsite\wok_init.bat" "%installPath%\site\"
xcopy "src\WOKsite\wok_tclsh.bat" "%installPath%\site\"
xcopy "src\WOKsite\wokinit.bat" "%installPath%\site\"

xcopy "src\CPPClient\CPPClient_General.edl" "%installPath%\lib\"
xcopy "src\CPPClient\CPPClient_Template.edl" "%installPath%\lib\"


rem from WOKBuilderDef to lib folder
xcopy "src\WOKBuilderDef\ARX.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CDLTranslate.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_AIX.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_BSD.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_HP.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_LIN.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_MAC.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_SIL.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_SUN.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CMPLRS_WNT.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CODEGEN.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\COMMAND.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CPP.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CPPCLIENT.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CPPENG.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CPPINT.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CPPJINI.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_AIX.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_AO1.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_BSD.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_HP.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_LIN.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_MAC.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_SIL.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_SUN.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSF_WNT.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\CSFDBSCHEMA.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\JAVA.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LD.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LDAR.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LDEXE.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LDSHR.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LIB.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LINK.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\LINKSHR.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\STUBS.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\TCPP.edl" "%installPath%\lib\"
xcopy "src\WOKBuilderDef\USECONFIG.edl" "%installPath%\lib\"

rem WOKTclLib to lib
xcopy "src\WOKTclLib\templates" "%installPath%\lib\templates" /i
xcopy "src\WOKTclLib\abstract.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\admin.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\arb.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\back.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\Browser.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\browser.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\BrowserOMT.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\BrowserSearch.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\bycol.xbm" "%installPath%\lib\"
xcopy "src\WOKTclLib\bylast.xbm" "%installPath%\lib\"
xcopy "src\WOKTclLib\bylong.xbm" "%installPath%\lib\"
xcopy "src\WOKTclLib\byrow.xbm" "%installPath%\lib\"
xcopy "src\WOKTclLib\caution.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\cback.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\ccl.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\ccl_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\cell.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\cfrwd.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\client.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\client_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\config.h" "%installPath%\lib\"
xcopy "src\WOKTclLib\create.xpm" "%installPath%\site\"
xcopy "src\WOKTclLib\danger.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\delete.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\delivery.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\delivery_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\dep.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\documentation.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\documentation_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\engine.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\engine_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\envir.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\envir_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\executable.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\executable_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\factory.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\factory_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\file.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\FILES" "%installPath%\lib\"
xcopy "src\WOKTclLib\frontal.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\frontal_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\gettable.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\idl.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\idl_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\interface.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\interface_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\jini.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\jini_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\journal.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\MkBuild.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\news_cpwb.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\nocdlpack.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\nocdlpack_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\notes.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\OCCTDocumentation.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\OCCTProductsDocumentation.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\OCCTDocumentationProcedures.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\OCCTGetVersion.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\opencascade.gif" "%installPath%\lib\"
xcopy "src\WOKTclLib\OS.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\osutils.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\package.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\package_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\params.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\parcel.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\parcel_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\patch.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\patches.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\path.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\persistent.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\pqueue.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\prepare.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\private.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\queue.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\README" "%installPath%\lib\"
xcopy "src\WOKTclLib\reposit.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\resource.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\resource_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\rotate.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\scheck.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\schema.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\schema_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\see.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\see_closed.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\server.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\server_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\source.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\storable.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\tclx.nt" "%installPath%\lib\"
xcopy "src\WOKTclLib\tclIndex" "%installPath%\lib\"
xcopy "src\WOKTclLib\textfile_adm.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\textfile_rdonly.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\toolkit.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\toolkit_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\transient.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\ud2cvs_unix" "%installPath%\lib\"
xcopy "src\WOKTclLib\unit.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\unit_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\unit_rdonly.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\upack.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\VC.example" "%installPath%\lib\"
xcopy "src\WOKTclLib\warehouse.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\wbuild.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wbuild.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wbuild.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\wcheck.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wcompare.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\WCOMPATIBLE.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wnews.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wnews_trigger.example" "%installPath%\lib\"
xcopy "src\WOKTclLib\wok.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wok-comm.el" "%installPath%\lib\"
xcopy "src\WOKTclLib\Wok_Init.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokcd.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokclient.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokCOO.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokCreations.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokcvs.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokDeletions.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokEDF.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokEDF.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokemacs.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokinit.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokinterp.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokMainHelp.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokNAV.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokPrepareHelp.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokPRM.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokPRM.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokprocs.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokPROP.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokQUE.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokRPR.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokRPRHelp.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokSEA.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\woksh.el" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokStuff.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\WOKVC.NOBASE" "%installPath%\lib\"
xcopy "src\WOKTclLib\WOKVC.RCS" "%installPath%\lib\"
xcopy "src\WOKTclLib\WOKVC.SCCS" "%installPath%\lib\"
xcopy "src\WOKTclLib\WOKVC.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wokWaffQueueHelp.hlp" "%installPath%\lib\"
xcopy "src\WOKTclLib\work.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\workbench.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\workbench_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\workbenchq.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\workshop.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\workshop_open.xpm" "%installPath%\lib\"
xcopy "src\WOKTclLib\wprepare.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wstore.tcl" "%installPath%\lib\"
xcopy "src\WOKTclLib\wstore_trigger.example" "%installPath%\lib\"
xcopy "src\WOKTclLib\wutils.tcl" "%installPath%\lib\"

echo.
echo =========end operation===========
if not "%doNotCopyForeignFileList%" == "" (
  echo "%doNotCopyForeignFileList% files has not been copied"
)
echo.
