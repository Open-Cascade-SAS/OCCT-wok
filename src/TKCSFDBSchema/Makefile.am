# Makefile.am for Open Cascade toolkit TKCSFDBSchema
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CSFDBSchema : @top_srcdir@/src/CSFDBSchema


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CSFDBSchema


lib_LTLIBRARIES=libTKCSFDBSchema.la

libTKCSFDBSchema_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCSFDBSchema_la_SOURCES = \
CSFDBSchema.cxx

