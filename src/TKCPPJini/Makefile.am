# Makefile.am for Open Cascade toolkit TKCPPJini
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/drv/CPPJini : @top_srcdir@/src/CPPJini


INCLUDES =  \
-I@top_srcdir@/inc \
-I@top_srcdir@/drv/CPPJini


lib_LTLIBRARIES=libTKCPPJini.la

libTKCPPJini_la_LIBADD = \
../TKWOK/libTKWOK.la \
../TKernel/libTKernel.la


libTKCPPJini_la_SOURCES = \
CPPJini.cxx \
CPPJini_ClientInfo.cxx \
CPPJini_DataMapIteratorOfDataMapOfAsciiStringInteger_0.cxx \
CPPJini_DataMapNodeOfDataMapOfAsciiStringInteger_0.cxx \
CPPJini_DataMapOfAsciiStringInteger_0.cxx \
CPPJini_Enum.cxx \
CPPJini_MPV.cxx \
CPPJini_Package.cxx \
CPPJini_SequenceNodeOfSequenceOfClientInfo_0.cxx \
CPPJini_SequenceOfClientInfo_0.cxx \
CPPJini_Transient.cxx

