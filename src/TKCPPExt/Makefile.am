# Makefile.am for Open Cascade toolkit TKCPPExt
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CPPExt : @top_srcdir@/src/CPPExt


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CPPExt


lib_LTLIBRARIES=libTKCPPExt.la

libTKCPPExt_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCPPExt_la_SOURCES = \
CPPExt.cxx \
CPPExt_Alias.cxx \
CPPExt_Enum.cxx \
CPPExt_Exception.cxx \
CPPExt_MPV.cxx \
CPPExt_Package.cxx \
CPPExt_PersistentCSFDB.cxx \
CPPExt_PersistentOBJS.cxx \
CPPExt_PersistentOBJY.cxx \
CPPExt_Pointer.cxx \
CPPExt_Storable.cxx \
CPPExt_Transient.cxx

