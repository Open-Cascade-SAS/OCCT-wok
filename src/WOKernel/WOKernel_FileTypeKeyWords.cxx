
#include <Standard_Macro.hxx>
#include <TCollection_HAsciiString.hxx>

//#include <WOKernel_FileTypeKeyWords.hxx>

//#define IMPLEMENT_WOK_STATIC(Name,Value) extern Standard_EXPORT const char Name [] = Value;
#define IMPLEMENT_WOK_STATIC(Name,Value) Standard_EXPORT const char *Name = Value;

IMPLEMENT_WOK_STATIC(WOKENTITY,"WOKEntity")
IMPLEMENT_WOK_STATIC(WOKENTITYFILELIST,"%WOKEntity_FileList")
IMPLEMENT_WOK_STATIC(WOKENTITYDIRLIST,"%WOKEntity_DirList")
IMPLEMENT_WOK_STATIC(WOKENTITYPARAMLIST,"%WOKEntity_ParamList")


//BuildCustomistation
IMPLEMENT_WOK_STATIC(WOKENTITYBEFOREBUID,"WOKEntity_BeforeBuild")
IMPLEMENT_WOK_STATIC(WOKENTITYAFTERBUILD,"WOKEntity_AfterBuild")
IMPLEMENT_WOK_STATIC(WOKENTITYBEFOREDESTROY,"WOKEntity_BeforeDestroy")
IMPLEMENT_WOK_STATIC(WOKENTITYAFTERDESTROY,"WOKEntity_AfterDestroy")

IMPLEMENT_WOK_STATIC(TYPEPREFIX,"WOKEntity_")



IMPLEMENT_WOK_STATIC(NESTINGVAR,"%Nesting")
IMPLEMENT_WOK_STATIC(NESTINGTYPEVAR,"%NestingType")
IMPLEMENT_WOK_STATIC(NESTINGPATHVAR,"%NestingPath")
IMPLEMENT_WOK_STATIC(NESTING_PREFIX,"%Nesting_")
IMPLEMENT_WOK_STATIC(NESTING_STATION,"%Nesting_Station")
IMPLEMENT_WOK_STATIC(NESTING_DBMS,"%Nesting_DBMS")
IMPLEMENT_WOK_STATIC(NESTING_DBMS_STATION,"%Nesting_DBMS_Station")

IMPLEMENT_WOK_STATIC(ENTITYVAR,"%Entity")
IMPLEMENT_WOK_STATIC(ENTITYTYPEVAR,"%EntityType")
IMPLEMENT_WOK_STATIC(ENTITYPATHVAR,"%EntityPath")
IMPLEMENT_WOK_STATIC(ENTITY_PREFIX,"%Entity_")
IMPLEMENT_WOK_STATIC(ENTITY_STATION,"%Entity_Station")
IMPLEMENT_WOK_STATIC(ENTITY_DBMS,"%Entity_DBMS")
IMPLEMENT_WOK_STATIC(ENTITY_DBMS_STATION,"%Entity_DBMS_Station")

IMPLEMENT_WOK_STATIC(STATION_SUFFIX,"Station")
IMPLEMENT_WOK_STATIC(DBMS_SUFFIX,"DBMS")
IMPLEMENT_WOK_STATIC(STATIONS_SUFFIX,"Stations")
IMPLEMENT_WOK_STATIC(DBMSYSTEMS_SUFFIX,"DBMSystems")

IMPLEMENT_WOK_STATIC(LOCALARCHVAR,"%LocalArch")
IMPLEMENT_WOK_STATIC(STATIONVAR,"%Station")
IMPLEMENT_WOK_STATIC(DBMSVAR,"%DBMS")
IMPLEMENT_WOK_STATIC(FILEVAR,"%File")






#define IMPLEMENT_WOK_STATIC_STRING(aStr) \
Standard_EXPORT const Handle(TCollection_HAsciiString)& WOK_STATIC_##aStr() {\
  static Handle(TCollection_HAsciiString) TheStaticString = new TCollection_HAsciiString((Standard_CString) aStr); \
  return TheStaticString; \
}

IMPLEMENT_WOK_STATIC_STRING(WOKENTITY)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYFILELIST)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYDIRLIST)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYPARAMLIST)



IMPLEMENT_WOK_STATIC_STRING(WOKENTITYBEFOREBUID)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYAFTERBUILD)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYBEFOREDESTROY)
IMPLEMENT_WOK_STATIC_STRING(WOKENTITYAFTERDESTROY)

IMPLEMENT_WOK_STATIC_STRING(TYPEPREFIX)



IMPLEMENT_WOK_STATIC_STRING(NESTINGVAR)
IMPLEMENT_WOK_STATIC_STRING(NESTINGTYPEVAR)
IMPLEMENT_WOK_STATIC_STRING(NESTINGPATHVAR)
IMPLEMENT_WOK_STATIC_STRING(NESTING_PREFIX)
IMPLEMENT_WOK_STATIC_STRING(NESTING_STATION)
IMPLEMENT_WOK_STATIC_STRING(NESTING_DBMS)
IMPLEMENT_WOK_STATIC_STRING(NESTING_DBMS_STATION)

IMPLEMENT_WOK_STATIC_STRING(ENTITYVAR)
IMPLEMENT_WOK_STATIC_STRING(ENTITYTYPEVAR)
IMPLEMENT_WOK_STATIC_STRING(ENTITYPATHVAR)
IMPLEMENT_WOK_STATIC_STRING(ENTITY_PREFIX)
IMPLEMENT_WOK_STATIC_STRING(ENTITY_STATION)
IMPLEMENT_WOK_STATIC_STRING(ENTITY_DBMS)
IMPLEMENT_WOK_STATIC_STRING(ENTITY_DBMS_STATION)

IMPLEMENT_WOK_STATIC_STRING(STATION_SUFFIX)
IMPLEMENT_WOK_STATIC_STRING(DBMS_SUFFIX)

IMPLEMENT_WOK_STATIC_STRING(LOCALARCHVAR)
IMPLEMENT_WOK_STATIC_STRING(STATIONVAR)
IMPLEMENT_WOK_STATIC_STRING(DBMSVAR)
IMPLEMENT_WOK_STATIC_STRING(FILEVAR)

