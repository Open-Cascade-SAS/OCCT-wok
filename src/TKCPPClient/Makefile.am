# Makefile.am for Open Cascade toolkit TKCPPClient
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CPPClient : @top_srcdir@/src/CPPClient


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CPPClient


lib_LTLIBRARIES=libTKCPPClient.la

libTKCPPClient_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCPPClient_la_SOURCES = \
CPPClient.cxx \
CPPClient_Enum.cxx \
CPPClient_MPV.cxx \
CPPClient_Package.cxx \
CPPClient_Transient.cxx

