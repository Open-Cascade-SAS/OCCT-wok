# Makefile.am for executable WOKLibs
srcdir = @srcdir@

VPATH = @srcdir@ : \
@top_srcdir@/src/WOKLibs

INCLUDES =$(CSF_SOCKETLibs_INCLUDES) $(CSF_FPELibs_INCLUDES) $(CSF_advapi32_INCLUDES) $(CSF_gdi32_INCLUDES) $(CSF_user32_INCLUDES)  \
-I@top_srcdir@/inc \
-I@top_srcdir@/src/WOKLibs

lib_LTLIBRARIES=libwokcmd.la libwokdeliverysteps.la \
libwokdfltsteps.la libwokobjssteps.la libwokorbixsteps.la \
libwoksteps.la libwoktoolscmd.la libwokutilscmd.la \
libmscmd.la

libwokdeliverysteps_la_LIBADD =../TKWOK/libTKWOK.la $(CSF_TclLibs_LIB) 

libwokcmd_la_LIBADD =../TKWOK/libTKWOK.la $(CSF_TclLibs_LIB) 

libwokdfltsteps_la_LIBADD =../TKWOK/libTKWOK.la $(CSF_TclLibs_LIB) 

libwokobjssteps_la_LIBADD =../TKWOK/libTKWOK.la $(CSF_TclLibs_LIB) 

libwokorbixsteps_la_LIBADD =../TKWOK/libTKWOK.la ${CSF_TclLibs_LIB)

libwoksteps_la_LIBADD =../TKWOK/libTKWOK.la  ${CSF_TclLibs_LIB)

libwoktoolscmd_la_LIBADD =../TKWOK/libTKWOK.la ${CSF_TclLibs_LIB)

libwokutilscmd_la_LIBADD =../TKWOK/libTKWOK.la ${CSF_TclLibs_LIB)

libmscmd_la_LIBADD =../TKWOK/libTKWOK.la ${CSF_TclLibs_LIB)

libwokdeliverysteps_la_SOURCES = wokdeliverysteps.cxx
libwokcmd_la_SOURCES = wokcmd.cxx
libwokdfltsteps_la_SOURCES = wokdfltsteps.cxx
libwokobjssteps_la_SOURCES = wokobjssteps.cxx
libwokorbixsteps_la_SOURCES = wokorbixsteps.cxx
libwoksteps_la_SOURCES = woksteps.cxx
libwoktoolscmd_la_SOURCES = woktoolscmd.cxx
libwokutilscmd_la_SOURCES = wokutilscmd.cxx
libmscmd_la_SOURCES = mscmd.cxx


