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

libwokdeliverysteps_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokcmd_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokdfltsteps_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokobjssteps_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokorbixsteps_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwoksteps_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwoktoolscmd_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokutilscmd_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

woksh_LDADD =../TKWOKTcl/libTKWOKTcl.la ../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

wokprocess_LDADD =../TKWOKTcl/libTKWOKTcl.la ../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libmscmd_la_LIBADD =../TKWOK/libTKWOK.la $(TK_LIB_SPEC) $(TCL_LIB_SPEC)

libwokdeliverysteps_la_SOURCES = wokdeliverysteps.cxx
libwokcmd_la_SOURCES = wokcmd.cxx
libwokdfltsteps_la_SOURCES = wokdfltsteps.cxx
libwokobjssteps_la_SOURCES = wokobjssteps.cxx
libwokorbixsteps_la_SOURCES = wokorbixsteps.cxx
libwoksteps_la_SOURCES = woksteps.cxx
libwoktoolscmd_la_SOURCES = woktoolscmd.cxx
libwokutilscmd_la_SOURCES = wokutilscmd.cxx
libmscmd_la_SOURCES = mscmd.cxx


