# Makefile.am for executable WOKSH
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/src/WOKSH

INCLUDES =$(CSF_TclLibs_INCLUDES) $(CSF_TclTkLibs_INCLUDES) $(CSF_SOCKETLibs_INCLUDES) $(CSF_FPELibs_INCLUDES) $(CSF_advapi32_INCLUDES) $(CSF_gdi32_INCLUDES) $(CSF_user32_INCLUDES)  \
-I@top_srcdir@/inc \
-I@top_srcdir@/src/WOKSH \
-I@top_srcdir@/drv/WOKSH

bin_PROGRAMS=wokprocess woksh

woksh_SOURCES = woksh.cxx
wokprocess_SOURCES = wokprocess.cxx

woksh_LDADD = \
../TKernel/libTKernel.la \
../TKWOK/libTKWOK

wokprocess_LDADD = \
../TKernel/libTKernel.la \
../TKWOK/libTKWOK

