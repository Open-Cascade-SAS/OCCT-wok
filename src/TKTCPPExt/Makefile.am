# Makefile.am for Open Cascade toolkit TKTCPPExt
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/TCPPExt : @top_srcdir@/src/TCPPExt


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/TCPPExt


lib_LTLIBRARIES=libTKTCPPExt.la

libTKTCPPExt_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKTCPPExt_la_SOURCES = \
TCPPExt.cxx

