#ifndef WNT
// File:	WOKUnix_MaxPipeSize.hxx
// Created:	Fri May 12 10:09:01 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>


#ifndef WOKUnix_MaxPipeSize_HeaderFile
#define WOKUnix_MaxPipeSize_HeaderFile


#ifdef HPUX
#include <sys/inode.h>
//#define MAX_PIPE_SIZE  PIPSIZ
#define MAX_PIPE_SIZE 8190
#elif  IRIX
#include <limits.h>
#define MAX_PIPE_SIZE PIPE_MAX
#elif  DECOSF1
#include <sys/param.h>
#define MAX_PIPE_SIZE PIPE_BUF
#elif SOLARIS
#include <sys/param.h>
#define MAX_PIPE_SIZE PIPE_MAX
#elif defined(LIN)
#include <limits.h>
#define MAX_PIPE_SIZE PIPE_BUF
#elif defined(AIX)
#include <limits.h>
#define MAX_PIPE_SIZE PIPE_BUF
#endif


#endif
#endif
