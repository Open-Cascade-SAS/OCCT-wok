# Makefile.am for Open Cascade toolkit TKCPPIntExt
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CPPIntExt : @top_srcdir@/src/CPPIntExt


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CPPIntExt


lib_LTLIBRARIES=libTKCPPIntExt.la

libTKCPPIntExt_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCPPIntExt_la_SOURCES = \
CPPIntExt.cxx \
CPPIntExt_Body.cxx \
CPPIntExt_Case.cxx \
CPPIntExt_Ccl.cxx \
CPPIntExt_EInit.cxx \
CPPIntExt_Load.cxx

