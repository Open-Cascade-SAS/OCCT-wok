# Makefile.am for Open Cascade toolkit TKIDLFront
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/IDLFront : @top_srcdir@/src/IDLFront


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/IDLFront


lib_LTLIBRARIES=libTKIDLFront.la

libTKIDLFront_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKIDLFront_la_SOURCES = \
IDL.tab.c \
IDLFront.cxx \
lex.IDL.c

