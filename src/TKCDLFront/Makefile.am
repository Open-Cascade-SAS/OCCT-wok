# Makefile.am for Open Cascade toolkit TKCDLFront
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CDLFront : @top_srcdir@/src/CDLFront


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CDLFront


lib_LTLIBRARIES=libTKCDLFront.la

libTKCDLFront_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCDLFront_la_SOURCES = \
CDL.tab.c \
CDLFront.cxx \
lex.CDL.c

