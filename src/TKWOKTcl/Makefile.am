# Makefile.am for Open Cascade toolkit TKWOKTcl
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/WOKTclUtils : @top_srcdir@/src/WOKTclUtils: \
@top_srcdir@/drv/WOKTclTools : @top_srcdir@/src/WOKTclTools: \
@top_srcdir@/drv/MSAPI : @top_srcdir@/src/MSAPI: \
@top_srcdir@/drv/WOKTCL : @top_srcdir@/src/WOKTCL


INCLUDES = $(CSF_TclLibs_INCLUDES) $(CSF_TclTkLibs_INCLUDES) \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/WOKTclUtils \
-I@top_srcdir@/drv/WOKTclTools \
-I@top_srcdir@/drv/MSAPI \
-I@top_srcdir@/drv/WOKTCL


lib_LTLIBRARIES=libTKWOKTcl.la

libTKWOKTcl_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la \
$(CSF_TclLibs_LIB) $(CSF_TclTkLibs_LIB) 

libTKWOKTcl_la_SOURCES = \
MSAPI_Class.cxx \
MSAPI_ExternMet.cxx \
MSAPI_GenClass.cxx \
MSAPI_InstClass.cxx \
MSAPI_MemberMet.cxx \
MSAPI_MetaSchema.cxx \
MSAPI_Method.cxx \
MSAPI_Package.cxx \
MSAPI_Schema.cxx \
MSAPI_StdClass.cxx \
WOKTCL_DefaultCommand.cxx \
WOKTCL_Interpretor.cxx \
WOKTCL_TriggerHandler.cxx \
WOKTclTools_Interpretor.cxx \
WOKTclTools_Messages.cxx \
WOKTclTools_MsgAPI.cxx \
WOKTclTools_Package.cxx \
WOKTclTools_TriggerHandler.cxx \
WOKTclUtils_Path.cxx

