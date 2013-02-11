#!/bin/bash

installRelatePath="package"
if [ "$1" != "" ]; then
  installRelatePath=$1
fi

mkdir -p $installRelatePath/doc
mkdir -p $installRelatePath/lib/lin
mkdir -p $installRelatePath/lib/templates
mkdir -p $installRelatePath/home
mkdir -p $installRelatePath/site/public_el/
mkdir -p $installRelatePath/wok_entities

cp -f src/WOKsite/tclshrc.tcl     $installRelatePath/home/
cp -f src/WOKsite/.emacs          $installRelatePath/home/
cp -f src/WOKsite/.tclshrc        $installRelatePath/home/

cp -f -R src/WOKsite/public_el/* $installRelatePath/site/public_el/

cp -f src/CPPJini/CPPJini_General.edl $installRelatePath/lib/
cp -f src/CPPJini/CPPJini_Template.edl $installRelatePath/lib/

cp -f src/WOKOBJS/OBJS.edl $installRelatePath/lib/
cp -f src/WOKOBJS/OBJSSCHEMA.edl $installRelatePath/lib/

cp -f src/WOKLibs/pkgIndex.tcl $installRelatePath/lib/

cp -f src/TCPPExt/TCPPExt_MethodTemplate.edl $installRelatePath/lib/

cp -f src/WOKDeliv/WOKDeliv_DelivExecSource.tcl $installRelatePath/lib/
cp -f src/WOKDeliv/WOKDeliv_FRONTALSCRIPT.edl $installRelatePath/lib/
cp -f src/WOKDeliv/WOKDeliv_LDSCRIPT.edl $installRelatePath/lib/

cp -f src/CSFDBSchema/CSFDBSchema_Template.edl $installRelatePath/lib/

cp -f src/WOKUtils/EDL.edl $installRelatePath/lib/

cp -f src/CPPIntExt/Engine_Template.edl $installRelatePath/lib/
cp -f src/CPPIntExt/Interface_Template.edl $installRelatePath/lib/

cp -f src/WOKTclTools/ENV.edl $installRelatePath/lib/

cp -f src/WOKEntityDef/FILENAME.edl $installRelatePath/lib/

cp -f src/CPPExt/CPPExt_Standard.edl $installRelatePath/lib/
cp -f src/CPPExt/CPPExt_Template.edl $installRelatePath/lib/
cp -f src/CPPExt/CPPExt_TemplateCSFDB.edl $installRelatePath/lib/
cp -f src/CPPExt/CPPExt_TemplateOBJS.edl $installRelatePath/lib/
cp -f src/CPPExt/CPPExt_TemplateOBJY.edl $installRelatePath/lib/

cp -f src/WOKOrbix/IDLFRONT.edl $installRelatePath/lib/
cp -f src/WOKOrbix/ORBIX.edl $installRelatePath/lib/
cp -f src/WOKOrbix/WOKOrbix_ClientObjects.tcl $installRelatePath/lib/
cp -f src/WOKOrbix/WOKOrbix_ServerObjects.tcl $installRelatePath/lib/

cp -f src/WOKEntityDef/WOKEntity.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Factory.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Parcel.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_ParcelUnit.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Unit.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_UnitTypes.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Warehouse.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Workbench.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_WorkbenchUnit.edl $installRelatePath/lib/
cp -f src/WOKEntityDef/WOKEntity_Workshop.edl $installRelatePath/lib/

cp -f src/WOKStep/WOKStep_frontal.tcl $installRelatePath/lib/
cp -f src/WOKStep/WOKStep_JavaCompile.tcl $installRelatePath/lib/
cp -f src/WOKStep/WOKStep_JavaHeader.tcl $installRelatePath/lib/
cp -f src/WOKStep/WOKStep_LibRename.tcl $installRelatePath/lib/
cp -f src/WOKStep/WOKStep_ManifestEmbed.tcl $installRelatePath/lib/
cp -f src/WOKStep/WOKStep_TclLibIdep.tcl $installRelatePath/lib/

cp -f src/WOKStepsDef/FRONTAL.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_ccl.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_client.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_client_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_Del.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_delivery.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_documentation.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_engine.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_engine_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_executable.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_executable_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_frontal.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_idl.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_interface.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_interface_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_jini.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_nocdlpack.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_nocdlpack_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_package.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_package_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_resource.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_schema.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_schema_DFLT.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_schema_OBJS.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_schema_OBJY.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_server.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_toolkit.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKSteps_toolkit_wnt.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsDeliv.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsDFLT.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsOBJS.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsOBJY.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsOrbix.edl $installRelatePath/lib/
cp -f src/WOKStepsDef/WOKStepsStep.edl $installRelatePath/lib/

cp -f src/WOKsite/wok.csh $installRelatePath/site/
cp -f src/WOKsite/wokinit.csh $installRelatePath/site/
cp -f src/WOKsite/DEFAULT.edl $installRelatePath/site/
cp -f src/WOKsite/WOKSESSION.edl $installRelatePath/site/
cp -f src/WOKsite/CreateFactory.tcl $installRelatePath/site/
cp -f src/WOKsite/interp.tcl $installRelatePath/site/
cp -f src/WOKsite/tclshrc.tcl $installRelatePath/site/
cp -f src/WOKsite/wok_deps.tcl $installRelatePath/site/
cp -f src/WOKsite/wok_depsgui.tcl $installRelatePath/site/
cp -f src/WOKsite/wok_tclshrc.tcl $installRelatePath/site/
cp -f src/WOKsite/wok_confgui.sh $installRelatePath/site/
cp -f src/WOKsite/wok_emacs.sh $installRelatePath/site/
cp -f src/WOKsite/wok_env.sh $installRelatePath/site/
cp -f src/WOKsite/wok_init.sh $installRelatePath/site/
cp -f src/WOKsite/wok_tclsh.sh $installRelatePath/site/
cp -f src/WOKsite/tclshrc_Wok $installRelatePath/site/

cp -f src/CPPClient/CPPClient_General.edl $installRelatePath/lib/
cp -f src/CPPClient/CPPClient_Template.edl $installRelatePath/lib/

# from WOKBuilderDef to lib folder
cp -f src/WOKBuilderDef/ARX.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CDLTranslate.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_AIX.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_BSD.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_HP.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_LIN.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_MAC.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_SIL.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_SUN.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CMPLRS_WNT.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CODEGEN.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/COMMAND.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CPP.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CPPCLIENT.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CPPENG.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CPPINT.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CPPJINI.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_AIX.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_AO1.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_BSD.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_HP.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_LIN.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_MAC.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_SIL.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_SUN.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSF_WNT.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/CSFDBSCHEMA.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/JAVA.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LD.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LDAR.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LDEXE.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LDSHR.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LIB.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LINK.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/LINKSHR.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/STUBS.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/TCPP.edl $installRelatePath/lib/
cp -f src/WOKBuilderDef/USECONFIG.edl $installRelatePath/lib/

cp -f src/WOKTclLib/templates/template.mam $installRelatePath/lib/
cp -f src/WOKTclLib/templates/template.mamx $installRelatePath/lib/

cp -r src/WOKTclLib/templates/* $installRelatePath/lib/templates/

cp -f src/WOKTclLib/tclIndex $installRelatePath/lib/
cp -f src/WOKTclLib/abstract.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/admin.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/arb.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/back.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/Browser.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/browser.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/BrowserOMT.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/BrowserSearch.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/bycol.xbm $installRelatePath/lib/
cp -f src/WOKTclLib/bylast.xbm $installRelatePath/lib/
cp -f src/WOKTclLib/bylong.xbm $installRelatePath/lib/
cp -f src/WOKTclLib/byrow.xbm $installRelatePath/lib/
cp -f src/WOKTclLib/caution.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/cback.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/ccl.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/ccl_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/cell.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/cfrwd.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/client.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/client_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/config.h $installRelatePath/lib/
cp -f src/WOKTclLib/create.xpm $installRelatePath/site/
cp -f src/WOKTclLib/danger.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/delete.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/delivery.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/delivery_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/dep.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/documentation.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/documentation_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/engine.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/engine_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/envir.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/envir_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/executable.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/executable_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/factory.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/factory_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/file.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/FILES $installRelatePath/lib/
cp -f src/WOKTclLib/frontal.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/frontal_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/gettable.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/idl.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/idl_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/interface.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/interface_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/jini.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/jini_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/journal.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/MkBuild.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/news_cpwb.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/nocdlpack.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/nocdlpack_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/notes.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/OCCTDocumentation.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/OCCTProductsDocumentation.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/OCCTDocumentationProcedures.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/OCCTGetVersion.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/opencascade.gif $installRelatePath/lib/
cp -f src/WOKTclLib/OS.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/osutils.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/package.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/package_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/params.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/parcel.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/parcel_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/patch.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/patches.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/path.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/persistent.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/pqueue.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/prepare.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/private.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/queue.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/README $installRelatePath/lib/
cp -f src/WOKTclLib/reposit.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/resource.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/resource_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/rotate.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/scheck.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/schema.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/schema_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/see.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/see_closed.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/server.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/server_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/source.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/storable.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/tclx.nt $installRelatePath/lib/
cp -f src/WOKTclLib/textfile_adm.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/textfile_rdonly.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/toolkit.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/toolkit_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/transient.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/ud2cvs_unix $installRelatePath/lib/
cp -f src/WOKTclLib/unit.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/unit_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/unit_rdonly.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/upack.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/VC.example $installRelatePath/lib/
cp -f src/WOKTclLib/warehouse.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/wbuild.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wbuild.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wbuild.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/wcheck.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wcompare.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/WCOMPATIBLE.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wnews.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wnews_trigger.example $installRelatePath/lib/
cp -f src/WOKTclLib/wok.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wok-comm.el $installRelatePath/lib/
cp -f src/WOKTclLib/Wok_Init.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokcd.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/wokclient.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokCOO.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokCreations.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokcvs.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokDeletions.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokEDF.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wokEDF.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokemacs.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokinit.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokinterp.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokMainHelp.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wokNAV.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokPrepareHelp.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wokPRM.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wokPRM.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokprocs.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokPROP.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokQUE.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokRPR.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokRPRHelp.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/wokSEA.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/woksh.el $installRelatePath/lib/
cp -f src/WOKTclLib/wokStuff.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/WOKVC.NOBASE $installRelatePath/lib/
cp -f src/WOKTclLib/WOKVC.RCS $installRelatePath/lib/
cp -f src/WOKTclLib/WOKVC.SCCS $installRelatePath/lib/
cp -f src/WOKTclLib/WOKVC.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wokWaffQueueHelp.hlp $installRelatePath/lib/
cp -f src/WOKTclLib/work.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/workbench.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/workbench_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/workbenchq.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/workshop.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/workshop_open.xpm $installRelatePath/lib/
cp -f src/WOKTclLib/wprepare.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wstore.tcl $installRelatePath/lib/
cp -f src/WOKTclLib/wstore_trigger.example $installRelatePath/lib/
cp -f src/WOKTclLib/wutils.tcl $installRelatePath/lib/
