// File:	WOKTclTools_ExitHandler.hxx
// Created:	Wed Aug 21 16:16:26 1996
// Author:	Jean GAUTIER
//		<jga@cobrax.paris1.matra-dtv.fr>


#ifndef WOKTclTools_ExitHandler_HeaderFile
#define WOKTclTools_ExitHandler_HeaderFile

#if defined( WNT ) && defined( TCL_VERSION_75 )
# include <tcl75.h>
#endif // WNT

#include <tcl.h>

typedef  Tcl_ExitProc* WOKTclTools_ExitHandler;


#endif
