// File:	WOKTools_MsgStreamPtr.hxx
// Created:	Wed Jul  2 12:02:31 1997
// Author:	Jean GAUTIER
//		<jga@hourax.paris1.matra-dtv.fr>


#ifndef WOKTools_MsgStreamPtr_HeaderFile
#define WOKTools_MsgStreamPtr_HeaderFile

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifdef HAVE_FSTREAM
# include <fstream>
#elif defined (HAVE_FSTREAM_H)
# include <fstream.h>
#endif

typedef ofstream* WOKTools_MsgStreamPtr;

#endif
