// File:	WOKernel_FileTypeKeyWords.hxx
// Created:	Wed Feb 28 16:57:08 1996
// Author:	Jean GAUTIER
//		<jga@cobrax>


#ifndef WOKernel_FileTypeKeyWords_HeaderFile
#define WOKernel_FileTypeKeyWords_HeaderFile

#include <Standard_Macro.hxx>
#include <TCollection_HAsciiString.hxx>

//#define DECLARE_WOK_STATIC(aStr) Standard_IMPORT extern const char aStr [];
#define DECLARE_WOK_STATIC(aStr) Standard_IMPORT const char *aStr ;

DECLARE_WOK_STATIC(WOKENTITY)
DECLARE_WOK_STATIC(WOKENTITYFILELIST)
DECLARE_WOK_STATIC(WOKENTITYDIRLIST)
DECLARE_WOK_STATIC(WOKENTITYPARAMLIST)


// Build Customistation
DECLARE_WOK_STATIC(WOKENTITYBEFOREBUID)
DECLARE_WOK_STATIC(WOKENTITYAFTERBUILD)
DECLARE_WOK_STATIC(WOKENTITYBEFOREDESTROY)
DECLARE_WOK_STATIC(WOKENTITYAFTERDESTROY)

DECLARE_WOK_STATIC(TYPEPREFIX)



DECLARE_WOK_STATIC(NESTINGVAR)
DECLARE_WOK_STATIC(NESTINGTYPEVAR)
DECLARE_WOK_STATIC(NESTINGPATHVAR)
DECLARE_WOK_STATIC(NESTING_PREFIX)
DECLARE_WOK_STATIC(NESTING_STATION)
DECLARE_WOK_STATIC(NESTING_DBMS)
DECLARE_WOK_STATIC(NESTING_DBMS_STATION)

DECLARE_WOK_STATIC(ENTITYVAR)
DECLARE_WOK_STATIC(ENTITYTYPEVAR)
DECLARE_WOK_STATIC(ENTITYPATHVAR)
DECLARE_WOK_STATIC(ENTITY_PREFIX)
DECLARE_WOK_STATIC(ENTITY_STATION)
DECLARE_WOK_STATIC(ENTITY_DBMS)
DECLARE_WOK_STATIC(ENTITY_DBMS_STATION)

DECLARE_WOK_STATIC(STATION_SUFFIX)
DECLARE_WOK_STATIC(DBMS_SUFFIX)
DECLARE_WOK_STATIC(STATIONS_SUFFIX)
DECLARE_WOK_STATIC(DBMSYSTEMS_SUFFIX)

DECLARE_WOK_STATIC(LOCALARCHVAR)
DECLARE_WOK_STATIC(STATIONVAR)
DECLARE_WOK_STATIC(DBMSVAR)
DECLARE_WOK_STATIC(FILEVAR)






#define DECLARE_WOK_STATIC_STRING(aStr) extern Standard_EXPORT  const Handle(TCollection_HAsciiString)& WOK_STATIC_##aStr();



DECLARE_WOK_STATIC_STRING(WOKENTITY)
DECLARE_WOK_STATIC_STRING(WOKENTITYFILELIST)
DECLARE_WOK_STATIC_STRING(WOKENTITYDIRLIST)
DECLARE_WOK_STATIC_STRING(WOKENTITYPARAMLIST)



DECLARE_WOK_STATIC_STRING(WOKENTITYBEFOREBUID)
DECLARE_WOK_STATIC_STRING(WOKENTITYAFTERBUILD)
DECLARE_WOK_STATIC_STRING(WOKENTITYBEFOREDESTROY)
DECLARE_WOK_STATIC_STRING(WOKENTITYAFTERDESTROY)

DECLARE_WOK_STATIC_STRING(TYPEPREFIX)



DECLARE_WOK_STATIC_STRING(NESTINGVAR)
DECLARE_WOK_STATIC_STRING(NESTINGTYPEVAR)
DECLARE_WOK_STATIC_STRING(NESTINGPATHVAR)
DECLARE_WOK_STATIC_STRING(NESTING_PREFIX)
DECLARE_WOK_STATIC_STRING(NESTING_STATION)
DECLARE_WOK_STATIC_STRING(NESTING_DBMS)
DECLARE_WOK_STATIC_STRING(NESTING_DBMS_STATION)

DECLARE_WOK_STATIC_STRING(ENTITYVAR)
DECLARE_WOK_STATIC_STRING(ENTITYTYPEVAR)
DECLARE_WOK_STATIC_STRING(ENTITYPATHVAR)
DECLARE_WOK_STATIC_STRING(ENTITY_PREFIX)
DECLARE_WOK_STATIC_STRING(ENTITY_STATION)
DECLARE_WOK_STATIC_STRING(ENTITY_DBMS)
DECLARE_WOK_STATIC_STRING(ENTITY_DBMS_STATION)

DECLARE_WOK_STATIC_STRING(STATION_SUFFIX)
DECLARE_WOK_STATIC_STRING(DBMS_SUFFIX)
DECLARE_WOK_STATIC_STRING(STATIONS_SUFFIX)
DECLARE_WOK_STATIC_STRING(DBMSYSTEMS_SUFFIX)

DECLARE_WOK_STATIC_STRING(LOCALARCHVAR)
DECLARE_WOK_STATIC_STRING(STATIONVAR)
DECLARE_WOK_STATIC_STRING(DBMSVAR)
DECLARE_WOK_STATIC_STRING(FILEVAR)

#endif
