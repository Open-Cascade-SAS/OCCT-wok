#ifdef WNT
#define EXPORT
#include <WOKNT_FindData.hxx>
#include <stdlib.h>
#include <io.h>
#include <sys/stat.h>

#include <Standard_Stream.hxx>
#include <OSD_WNT.hxx>
#include <OSD_WNT_1.hxx>
#include <OSD_File.hxx>
#include <OSD_Path.hxx>
#include <OSD_Protection.hxx>

typedef struct _delete_data {

                BOOL forceReadOnly;
                BOOL fRecurse;

               } DELETE_DATA, *PDELETE_DATA;

typedef BOOL ( *RM_FUNC ) ( LPCTSTR, BOOL, void* );

static BOOL _rm_func     ( LPTSTR, BOOL, void* );
static void _print_error ( LPCTSTR );

static int nFiles;

#define USAGE() { cerr << "Usage: wokRM [-rfq] file(s)\n"; return ( 1 ); }

extern "C" __declspec( dllexport ) int wokRM ( int, char** );

int wokRM ( int argc, char** argv ) {

 int         i, retVal = 0;
 char*       ptr;
 DELETE_DATA dd = { FALSE, FALSE };
 char        buff[ _MAX_PATH ];
 char        path[ _MAX_PATH ];
 char        name[ _MAX_FNAME + _MAX_EXT ];
 char        drive[ _MAX_DRIVE ];
 char        dir[ _MAX_DIR ];
 char        fname[ _MAX_FNAME ];
 char        ext[ _MAX_EXT ];
 BOOL        fQuiet = FALSE;

 if ( argc < 2 ) USAGE();

 for ( i = 1; i < argc; ++i ) {
 
  if ( argv[ i ][ 0 ] == '-' ) {
  
   ptr = argv[ i ];

   while ( *++ptr != 0 ) {
   
    switch ( *ptr ) {
    
     case 'f':
     case 'F':

      dd.forceReadOnly = TRUE;

     break;

     case 'r':
     case 'R':

      dd.fRecurse = TRUE;

     break;

     case 'q':
     case 'Q':

      fQuiet = TRUE;

     break;

     default:

      USAGE();

    }  // end switch
   
   }  // end while
  
  } else 

   break;
 
 }  // end for

 if ( i == argc ) USAGE();

 for ( ; i < argc; ++i ) {
 
  nFiles = 0;

  strcpy ( buff, argv[ i ] );

  if (
   GetFileAttributes ( buff ) == FILE_ATTRIBUTE_DIRECTORY &&
   dd.fRecurse
  ) strcat ( buff, "/*.*" );

  _splitpath ( buff, drive, dir, fname, ext );
  _makepath  ( path, drive, dir, NULL, NULL );
  _makepath  ( name, NULL, NULL, fname, ext );

  if (  !DirWalk ( path, name, ( RM_FUNC )_rm_func, dd.fRecurse, &dd )  ) retVal = 1;
 
  if ( nFiles == 0 && !fQuiet ) {
  
   cerr << "wokRM: could not find " << argv[ i ] << endl << flush;
   retVal = 1;
  
  }  // end if

 }  // end for

 return retVal;
 
}  // end main

static BOOL _rm_func ( LPTSTR fileName, BOOL fDir, void* data ) {
 
 BOOL         fRetry = FALSE;
 BOOL         status = FALSE;
 PDELETE_DATA pData = ( PDELETE_DATA )data;

 ++nFiles;

 if ( pData -> forceReadOnly ) _chmod ( fileName, _S_IREAD | _S_IWRITE );
retry:
 if ( !fDir )

  status = DeleteFile ( fileName );

 else if ( pData -> fRecurse ) {

  cerr << fileName << endl;
  status = RemoveDirectoryA ( fileName );

 }

 if ( !status )

  if (  GetLastError () == ERROR_ACCESS_DENIED &&
        pData -> forceReadOnly                 &&
        !fRetry
  ) {
 
   OSD_File             aFile;
   OSD_Protection       aProt;
   OSD_SingleProtection aPrt;

   aFile.SetPath (  OSD_Path ( fileName )  );
   aProt = aFile.Protection ();
   aPrt  = aProt.User ();
   aProt.Add ( aPrt, OSD_RWXD );
   aProt.SetUser ( aPrt );
   aFile.SetProtection ( aProt );
   _chmod ( fileName, _S_IREAD | _S_IWRITE );

   fRetry = TRUE;
  
   goto retry;
 
  } else
 
   _print_error ( fileName );

 return status;

}  // end _deletreProc

static void _print_error ( LPCTSTR fName ) {

 DWORD              errCode;
 Standard_Character buffer[ 2048 ];

 errCode = GetLastError ();

 if (  !FormatMessage (
         FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ARGUMENT_ARRAY,
         0, errCode, MAKELANGID( LANG_NEUTRAL, SUBLANG_NEUTRAL ),
         buffer, 2048, NULL
        )
 ) {
 
  sprintf ( buffer, "error code %d", (Standard_Integer)errCode );
  SetLastError ( errCode );

 }  // end if

 cerr << "wokRM: could not remove " << fName << " - " << buffer << endl << flush;

}  // end _set_error

BOOL DirWalk (LPCTSTR theDirName,
              LPCTSTR theWildCard,
              BOOL  (*theFunc )(LPCTSTR , BOOL , void* ),
              BOOL    theRecurse,
              void*   theClientData)
{
  HANDLE aHeap = GetProcessHeap();
  PWIN32_FIND_DATA aFindData = (PWIN32_FIND_DATA )HeapAlloc (aHeap, 0, sizeof(WIN32_FIND_DATA));
  if (aFindData == NULL)
  {
    return FALSE;
  }

  LPTSTR aName = (LPTSTR )HeapAlloc (aHeap, 0, lstrlen (theDirName) + lstrlen (theWildCard) + sizeof(TEXT('\x00')));
  if (aName == NULL)
  {
    HeapFree (aHeap, 0, aFindData);
    return FALSE;
  }
  lstrcpy (aName, theDirName);
  lstrcat (aName, theWildCard);

  LPTSTR aFullName = NULL;
  BOOL   aRetVal   = TRUE;
  HANDLE hFindFile = FindFirstFile (aName, aFindData);
  for (BOOL hasNext = hFindFile != INVALID_HANDLE_VALUE; hasNext; hasNext = FindNextFile (hFindFile, aFindData))
  {
    if (aFindData->cFileName[0] != TEXT('.') ||
        aFindData->cFileName[0] != TEXT('.') &&
        aFindData->cFileName[1] != TEXT('.'))
    {
      aFullName = (LPTSTR )HeapAlloc (aHeap, 0,
                                      lstrlen (theDirName) + lstrlen (aFindData->cFileName)
                                    + sizeof(TEXT('/')) + sizeof(TEXT('\x00')));
      if (aFullName == NULL)
      {
        aRetVal = FALSE;
        break;
      }
    }

    lstrcpy (aFullName, theDirName);
    lstrcat (aFullName, aFindData->cFileName);
    if (aFindData->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY
     && theRecurse)
    {
      lstrcat (aFullName, TEXT("/"));
      if (!DirWalk (aFullName, theWildCard, theFunc, theRecurse, theClientData))
      {
        aRetVal = FALSE;
      }
    }
    else if (!theFunc (aFullName, aFindData->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY ? TRUE : FALSE, theClientData))
    {
      aRetVal = FALSE;
    }

    HeapFree (aHeap, 0, aFullName);
    aFullName = NULL;
  }
  if (hFindFile != INVALID_HANDLE_VALUE)
  {
    FindClose (hFindFile);
  }

  if (theRecurse)
  {
    LPTSTR aTmp = NULL;
    int aLen = lstrlen (theDirName) - 1;
    if (aLen > 0
     && theDirName[aLen] == TEXT('/'))
    {
      aTmp = (LPTSTR )HeapAlloc (aHeap, 0, aLen + 2);
      if (aTmp != NULL)
      {
        lstrcpy (aTmp, theDirName);
        aTmp[aLen] = 0;
        aRetVal = theFunc (aTmp != NULL ? aTmp : theDirName, TRUE, theClientData);
        HeapFree (aHeap, 0, aTmp);
      }
      else
      {
        aRetVal = FALSE;
        aLen    = 0;
      }
    }
  }

  if (aFullName != NULL) HeapFree (aHeap, 0, aFullName);
  if (aName     != NULL) HeapFree (aHeap, 0, aName    );
  if (aFindData != NULL) HeapFree (aHeap, 0, aFindData);

  return aRetVal;
}

#endif
