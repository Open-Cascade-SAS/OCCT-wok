// File:	WOKBuilder_Linker.cxx
// Created:	Tue Oct 24 13:37:07 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>


#include <fstream.h>

#include <WOKTools_Messages.hxx>

#include <WOKUtils_Path.hxx>
#include <WOKUtils_Shell.hxx>

#include <WOKBuilder_HSequenceOfObjectFile.hxx>
#include <WOKBuilder_HSequenceOfEntity.hxx>
#include <WOKBuilder_ObjectFile.hxx>
#include <WOKBuilder_SharedLibrary.hxx>
#include <WOKBuilder_Miscellaneous.hxx>

#include <EDL_API.hxx>

#include <TColStd_HSequenceOfHAsciiString.hxx>

#include <WOKBuilder_Linker.ixx>

//=======================================================================
//function : WOKBuilder_Linker
//purpose  : 
//=======================================================================
WOKBuilder_Linker::WOKBuilder_Linker(const Handle(TCollection_HAsciiString)& aname,
				     const WOKUtils_Param& params)
  : WOKBuilder_ToolInShell(aname, params)
{
}

//=======================================================================
//function : Load
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::Load()
{
  return;
}

//=======================================================================
//function : ObjectList
//purpose  : 
//=======================================================================
Handle(WOKBuilder_HSequenceOfObjectFile) WOKBuilder_Linker::ObjectList() const 
{
  return myobjects;
}

//=======================================================================
//function : SetObjectList
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetObjectList(const Handle(WOKBuilder_HSequenceOfObjectFile)& objects)
{
  myobjects = objects;
}

//=======================================================================
//function : TargetName
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::TargetName() const 
{
  return myname;
}

//=======================================================================
//function : SetTargetName
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetTargetName(const Handle(TCollection_HAsciiString)& aname)
{ 
  myname = aname;
}

//=======================================================================
//function : LibraryRefLine
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::LibraryRefLine(const Handle(WOKBuilder_Library)& alib) 
{
  Handle(TCollection_HAsciiString) line;
  Handle(TCollection_HAsciiString) templ;
  Standard_CString templname;

  if(alib.IsNull())
    return line;

  if(!IsLoaded()) Load();

  if(alib->Name().IsNull())
    {
      if(alib->Path().IsNull())
	return line;

      alib->SetDirectory(new WOKUtils_Path(alib->Path()->DirName()));
      
      Handle(TCollection_HAsciiString) name = alib->Path()->BaseName();
      name->Remove(1,3);
      
      alib->SetName(name);
    }

  switch(alib->ReferenceType())
    {
    case WOKBuilder_ShortRef:
      templname = "ShortRef";
      break;
    case WOKBuilder_LongRef:
      templname = "LongRef";
      break;
    case WOKBuilder_FullPath:
      if(alib->IsKind(STANDARD_TYPE(WOKBuilder_SharedLibrary))) 
	templname = "SharedFullPath";
      else
	templname = "ArchiveFullPath";
      break;
    default:
      ErrorMsg << "WOKBuilder_Linker::LibraryRefLine" << "Unknown Library Ref Type" << endm;
      return line;
    }
  
  templ = EvalToolParameter(templname);

  if(templ.IsNull())
    {
      ErrorMsg << "WOKBuilder_Linker::LibraryRefLine" << "Could not eval parameter : " << templname << endm;
      return line;
    }

  Params().Set("%LibDir", alib->Directory()->Name()->ToCString());
  Params().Set("%LibName", alib->Name()->ToCString());

  line = Params().Eval(templ->ToCString());
  return line;
}

//=======================================================================
//function : LibrarySearchPathes
//purpose  : 
//=======================================================================
Handle(WOKUtils_HSequenceOfPath) WOKBuilder_Linker::LibrarySearchPathes() const 
{
  return mylibpathes;
}

//=======================================================================
//function : SetLibrarySearchPathes
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetLibrarySearchPathes(const Handle(WOKUtils_HSequenceOfPath)& libpathes)
{
  mylibpathes = libpathes;
}

//=======================================================================
//function : DatabaseDirectories
//purpose  : 
//=======================================================================
Handle(WOKUtils_HSequenceOfPath) WOKBuilder_Linker::DatabaseDirectories() const 
{
  return mydbdirs;
}

//=======================================================================
//function : SetDatabaseDirectories
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetDatabaseDirectories(const Handle(WOKUtils_HSequenceOfPath)& dbdirs)
{
  mydbdirs = dbdirs;
}

//=======================================================================
//function : LibraryList
//purpose  : 
//=======================================================================
Handle(WOKBuilder_HSequenceOfLibrary) WOKBuilder_Linker::LibraryList() const 
{
  return mylibs;
}

//=======================================================================
//function : SetLibraryList
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetLibraryList(const Handle(WOKBuilder_HSequenceOfLibrary)& asharedlist)
{
  mylibs = asharedlist;
}

//=======================================================================
//function : Externals
//purpose  : 
//=======================================================================
Handle(TColStd_HSequenceOfHAsciiString) WOKBuilder_Linker::Externals() const
{
  return myexterns;
}

//=======================================================================
//function : SetExternals
//purpose  : 
//=======================================================================
void WOKBuilder_Linker::SetExternals(const Handle(TColStd_HSequenceOfHAsciiString)& externals)
{
  myexterns = externals;
}

//=======================================================================
//function : EvalHeader
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalHeader()
{
  Handle(TCollection_HAsciiString) line;
  Handle(TCollection_HAsciiString) templ;
  Handle(TColStd_HSequenceOfHAsciiString) varseq = new TColStd_HSequenceOfHAsciiString;

  if(!IsLoaded()) Load();

  templ = EvalToolParameter("Header");

  if(templ.IsNull()) return line;

 
  Params().Set("%Target", TargetName()->ToCString());

  line = Params().Eval(templ->ToCString());

  if(line.IsNull()) return line;

  line->AssignCat(EvalLibSearchDirectives());
  line->AssignCat(EvalDatabaseDirectives());

  return line;
}

//=======================================================================
//function : EvalLibSearchDirectives
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalLibSearchDirectives()
{
  Handle(TCollection_HAsciiString) res = new TCollection_HAsciiString;

  if(!mylibpathes.IsNull())
    {
      Standard_Integer i;
      
      for(i=1; i<=mylibpathes->Length(); i++)
	{
	  Handle(TCollection_HAsciiString) directive;

	  Params().Set("%LibDir", mylibpathes->Value(i)->Name()->ToCString());

	  directive = Params().Eval("LD_LibSearchPath");

	  if(!directive.IsNull())
	    {
	      res->AssignCat(directive);
	    }
	  else
	    {
	      WarningMsg << "WOKBuilder_Linker::EvalLibSearchDirectives" 
		<< "Could not eval lib directive: LD_LibSearchPath" << endm;
	    }
	}
    }

  return res;
}

//=======================================================================
//function : EvalDatabaseDirectives
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalDatabaseDirectives()
{
  Handle(TCollection_HAsciiString) res = new TCollection_HAsciiString;

  if(!mydbdirs.IsNull())
    {
      Standard_Integer i;
      
      for(i=1; i<=mydbdirs->Length(); i++)
	{
	  Handle(TCollection_HAsciiString) directive;

	  Params().Set("%DBDir", mydbdirs->Value(i)->Name()->ToCString());

	  directive = Params().Eval("LD_DBDirective");
	  if(!directive.IsNull()) 
	    {
	      res->AssignCat(directive);
	    }
	  else
	    {
	      WarningMsg << "WOKBuilder_Linker::EvalDatabaseDirectives" 
		<< "Could not eval database directive: LD_DBDirective" << endm;
	    }
	}
    }
   else
    {
      Params().Set("%DBDirectives", " ");
    }

  return res;
}

//=======================================================================
//function : EvalObjectList
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalObjectList()
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString)         templ;
  Handle(TCollection_HAsciiString)          line;

  if(!IsLoaded()) Load();
  
  templ = EvalToolParameter("ObjectRef");

  if(templ.IsNull()) return line;

  line = new TCollection_HAsciiString;

  for(i=1; i<=myobjects->Length(); i++)
    {
      Params().Set("%ObjectPath", myobjects->Value(i)->Path()->Name()->ToCString());
      line->AssignCat(Params().Eval(templ->ToCString()));
    }
  return line;
}

//=======================================================================
//function : EvalLibraryList
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalLibraryList()
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString) line;

  line = new TCollection_HAsciiString;

  for(i=1; i<=mylibs->Length(); i++)
    {
      line->AssignCat(LibraryRefLine(mylibs->Value(i)));
    }
  return line;
}


//=======================================================================
//function : EvalFooter
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKBuilder_Linker::EvalFooter()
{
  Handle(TCollection_HAsciiString) line = new TCollection_HAsciiString;
  Handle(TCollection_HAsciiString) templ, exttempl, astr;
  Standard_Integer i;

  if(!IsLoaded()) Load();

  exttempl = EvalToolParameter("ExternRef");

  for(i=1; i<=myexterns->Length(); i++)
    {
      astr = Params().Eval(myexterns->Value(i)->ToCString(), Standard_True);
      
      if(astr.IsNull())
	{
	  WarningMsg << "WOKBuilder_Linker::EvalFooter" 
		     << "Could not eval ExternLib : " << myexterns->Value(i) << endm;
	}
      else
	{
	  Params().Set("%ExternRef", astr->ToCString());
	  line->AssignCat(Params().Eval(exttempl->ToCString()));
	}
    }

  templ = EvalToolParameter("Footer");

  if(templ.IsNull())
    {
      ErrorMsg << "WOKBuilder_Linker::EvalFooter" << "Could not eval parameter : " << Name() << "_Footer" << endm;
      return line;
    }
  
  Params().Set("%Target", TargetName()->ToCString());

  line->AssignCat(Params().Eval(templ->ToCString()));
  return line;
}


//=======================================================================
//function : GetLinkerProduction
//purpose  : 
//=======================================================================
Handle(WOKBuilder_HSequenceOfEntity) WOKBuilder_Linker::GetLinkerProduction()
{
  return new WOKBuilder_HSequenceOfEntity;
}

//=======================================================================
//function : Execute
//purpose  : 
//=======================================================================
WOKBuilder_BuildStatus WOKBuilder_Linker::Execute()
{
  Standard_Integer i=0;
  Handle(WOKBuilder_HSequenceOfEntity) aseq = new WOKBuilder_HSequenceOfEntity;
  Handle(TColStd_HSequenceOfHAsciiString) errmsgs;

  if(!Shell()->IsLaunched()) Shell()->Launch();
  if(!IsLoaded()) Load();

  Shell()->ClearOutput();
  
  // 
  //// Calcul de la liste des objets
  //
  Handle(TCollection_HAsciiString) filename = new TCollection_HAsciiString(TargetName());
  filename->AssignCat(".ObjList");
  
  Handle(WOKUtils_Path) objlistpath = new WOKUtils_Path(OutputDir()->Name(), filename);
  
  ofstream objstream(objlistpath->Name()->ToCString());
  
  if(!objstream.good())
    {
      ErrorMsg << "WOKBuilder_Linker::Execute" 
	       << "Could not open " << objlistpath->Name() << " for writing" << endm;
      return WOKBuilder_Failed;
    }

  
  for(i=1; i<=myobjects->Length(); i++)
    {
      objstream << myobjects->Value(i)->Path()->Name()->ToCString() << endl;
    }

  objstream.close();

  Params().Set("%LD_ObjList", objlistpath->Name()->ToCString()); 

  Shell()->Send(EvalHeader());
  Shell()->Send(EvalObjectList());
  Shell()->Send(EvalLibraryList());
  Shell()->Execute(EvalFooter());

  if(Shell()->Status())
    {
      Standard_Boolean ph = ErrorMsg.PrintHeader();

      ErrorMsg << "WOKBuilder_Linker::Execute" << "Errors Occured :" << endm;

      errmsgs = Shell()->Errors();
      ErrorMsg.DontPrintHeader();
      for(Standard_Integer i=1; i<= errmsgs->Length(); i++)
	{
	  ErrorMsg << "WOKBuilder_Linker::Execute" << errmsgs->Value(i) << endm;
	}
      if(ph) ErrorMsg.DoPrintHeader();
      return WOKBuilder_Failed;
    }
  else
    {
      Standard_Boolean ph = InfoMsg.PrintHeader();
      InfoMsg.DontPrintHeader();
      errmsgs = Shell()->Errors();
      for(Standard_Integer i=1; i<= errmsgs->Length(); i++)
	{
	  InfoMsg << "WOKBuilder_Linker::Execute" << errmsgs->Value(i) << endm;
	}
      if(ph) InfoMsg.DoPrintHeader();
    }

  Shell()->ClearOutput();

  SetProduction(GetLinkerProduction());
  Produces()->Append(new WOKBuilder_Miscellaneous(objlistpath));
  
  return WOKBuilder_Success;
}
