// File:	WOKUnix_FDSet.hxx
// Created:	Tue May  9 15:25:38 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>


#ifndef WOKUnix_FDSet_HeaderFile
#define WOKUnix_FDSet_HeaderFile

#ifndef HPUX
#include <sys/select.h>
#define WOKUnix_FDSet_CAST fd_set *
#endif

#ifdef HPUX
#include <sys/param.h>
#include <sys/types.h>
#include <sys/time.h>
#define WOKUnix_FDSet_CAST fd_set *
#endif

typedef fd_set WOKUnix_FDSet;

#endif

