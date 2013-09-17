// File:	WOKUtils_Timeval.hxx
// Author:	Jean GAUTIER
//		<jga@cobrax>


#ifndef WOKNT_FindData_HeaderFile
#define WOKNT_FindData_HeaderFile

#ifdef WNT
#include <windows.h>

typedef WIN32_FIND_DATA WOKNT_FindData;

#ifdef CreateFile
# undef CreateFile
#endif  // CreateFile

#ifdef CreateDirectory
# undef CreateDirectory
#endif  // CreateFile

#ifdef RemoveDirectory
# undef RemoveDirectory
#endif  // CreateFile

extern BOOL DirWalk (LPCTSTR theDirName,
                     LPCTSTR theWildCard,
                     BOOL  (*theFunc )(LPCTSTR , BOOL , void* ),
                     BOOL    theRecurse,
                     void*   theClientData);

#else


typedef int WOKNT_FindData ;


#endif

#endif
