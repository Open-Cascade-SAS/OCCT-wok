#include <WOKBuilder_WNTCollector.ixx>

#include <WOKTools_Messages.hxx>

#include <OSD_Protection.hxx>

#include <WOKBuilder_ObjectFile.hxx>
#include <WOKBuilder_ExportLibrary.hxx>
#include <WOKBuilder_HSequenceOfEntity.hxx>

#include <WOKUtils_Path.hxx>
#include <WOKUtils_Param.hxx>
#include <WOKUtils_Shell.hxx>
#include <WOKUtils_RegExp.hxx>

#include <TColStd_HSequenceOfHAsciiString.hxx>

#ifdef WNT
# define FASTCALL __fastcall
#else
# define FASTCALL
#endif //WNT

static void FASTCALL _print_output ( Standard_CString, WOKBuilder_Tool* );
static void FASTCALL _delete_file  (  const Handle( TCollection_HAsciiString )&  );

WOKBuilder_WNTCollector::WOKBuilder_WNTCollector (const Handle(TCollection_HAsciiString)& aName,
						  const WOKUtils_Param&                   aParams)
: WOKBuilder_ToolInShell ( aName, aParams ) 
{
}

void WOKBuilder_WNTCollector::SetTargetName(const Handle( TCollection_HAsciiString )& aName)
{
  Params ().Set (  "%CollectorOutput", aName -> ToCString ()  );
  myTargetName = aName;
}

Standard_Boolean WOKBuilder_WNTCollector::OpenCommandFile() 
{
  Standard_Boolean retVal = Standard_False;

  Handle(TCollection_HAsciiString) ext = EvalCFExt();

 if(ext.IsNull()) 
   {
     ErrorMsg << "WOKBuilder_WNTCollector::OpenCommandFile"
       << "Could not evaluate extension for tool command file" << endm;
   }
 else 
   {
     Handle(TCollection_HAsciiString) fileName = new TCollection_HAsciiString(myTargetName);
     fileName->AssignCat(ext);

     myCommandFile.SetPath(OSD_Path(fileName->String()));
     myCommandFile.Build(OSD_WriteOnly, OSD_Protection());

     if(myCommandFile.Failed())
       {
	 ErrorMsg << "WOKBuilder_WNTCollector :: OpenCommandFile"
	   << "Could not create tool command file '" << fileName << "' - " << endm;
	 myCommandFile.Perror ();
       } 
     else
       retVal = Standard_True;
   }
  return retVal;
}

Standard_Boolean WOKBuilder_WNTCollector::CloseCommandFile()
{
  Standard_Boolean retVal = Standard_False;

  myCommandFile.Close();

  if(myCommandFile.Failed()) 
    {
      ErrorMsg << "WOKBuilder_WNTCollector :: OpenCommandFile"
	<< "Could not create tool command file - " << endm;
      myCommandFile.Perror ();  
    }
  else
    retVal = Standard_True;
  return retVal;
}

void WOKBuilder_WNTCollector::ProduceObjectList(const Handle(WOKBuilder_HSequenceOfObjectFile)& anObjectList) 
{
  for( Standard_Integer i=1; i<=anObjectList->Length(); ++i) 
    {
      TCollection_AsciiString line = anObjectList->Value(i)->Path()->Name()->String();

      line.AssignCat("\r\n");
      myCommandFile.Write(line,line.Length());
    }
}

WOKBuilder_BuildStatus WOKBuilder_WNTCollector::Execute() 
{
  static Handle(WOKUtils_RegExp) linkerLogo = new WOKUtils_RegExp (new TCollection_HAsciiString("[ \t]*Creating library.* and object.*"));

  Standard_Integer                          i;
  TCollection_AsciiString                 cmdFile;
  OSD_Path                                cmdPath;
  Handle(WOKUtils_Path)                   prodPath;
  Handle(TColStd_HSequenceOfHAsciiString) errmsgs;
  Handle(TCollection_HAsciiString)        cmdFileName;

  myCommandFile.Path(cmdPath);
  cmdPath.SystemName(cmdFile);
  
  if(!Shell()->IsLaunched()) Shell()->Launch();
  
  Shell()->ClearOutput();

  Shell()->Send(EvalHeader());
  Shell()->Send(new TCollection_HAsciiString("@"));
  Shell()->Send(cmdFileName = new TCollection_HAsciiString(cmdFile));
  Shell()->Send(new TCollection_HAsciiString(" "));
  Shell()->Send(EvalFooter());

  _print_output("Creating   : ", this);

  Shell()->Execute(new TCollection_HAsciiString(" "));

  _delete_file(cmdFileName);

  if(Shell()->Status())
    {
      Standard_Boolean ph = ErrorMsg.PrintHeader();

      ErrorMsg << "WOKBuilder_WNTCollector :: Execute" << "Errors Occured :" << endm;

      errmsgs = Shell()->Errors();

      ErrorMsg.DontPrintHeader();
      
      for( i=1; i<=errmsgs->Length(); i++) 
	{
	  if(linkerLogo->Match(errmsgs->Value(i)) != -1) continue;

	  ErrorMsg << "WOKBuilder_WNTCollector :: Execute" << errmsgs -> Value ( i ) << endm;
	}  
      
      if(ph) ErrorMsg.DoPrintHeader();

      _print_output("Failed     : ", this);

      Shell()->ClearOutput();

      return WOKBuilder_Failed;
    }
  else
    {
      Handle(WOKBuilder_Entity) ent;
      Standard_Boolean          ph = InfoMsg.PrintHeader();

      InfoMsg << "WOKBuilder_WNTCollector::Execute" << "Succeeded  : ";

      for( i=1; i<=Produces()->Length(); ++i)
	{
	  ent = Produces()->Value(i);

	  if(ent->IsKind(STANDARD_TYPE(WOKBuilder_ExportLibrary))) continue;
	  
	  prodPath = ent->Path();
	  if(prodPath->Exists())
	    InfoMsg << prodPath->FileName() << " ";
	} 

      InfoMsg << endm;
      InfoMsg.DontPrintHeader();
  
      errmsgs = Shell()->Errors();

      for( i=1; i<=errmsgs->Length(); i++)
	{
	  if(linkerLogo->Match(errmsgs->Value(i))!=-1) continue;

	  InfoMsg << "WOKBuilder_WNTCollector::Execute" << errmsgs->Value(i) << endm;
	}

      if(ph) InfoMsg.DoPrintHeader();
    }
  
  Shell()->ClearOutput();
  
  return WOKBuilder_Success;
}

static void FASTCALL  _print_output( Standard_CString msg, WOKBuilder_Tool* tool)
{
  Handle(WOKBuilder_Entity) ent;
  
  InfoMsg << "WOKBuilder_WNTCollector::Execute"
    << msg;

  for(Standard_Integer i=1; i<=tool->Produces()->Length(); ++i) 
    {
      ent = tool->Produces()->Value(i);

      if(ent->IsKind(STANDARD_TYPE(WOKBuilder_ExportLibrary))) continue;

      InfoMsg <<  ent -> Path () -> FileName () << " ";
    }

  InfoMsg << endm;
}

static void FASTCALL _delete_file(const Handle(TCollection_HAsciiString)& name) 
{
 Handle(WOKUtils_Path) path = new WOKUtils_Path(name);
 
 if(path->Exists()) path->RemoveFile();
}
