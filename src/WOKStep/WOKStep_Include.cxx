// File:	WOKStep_Include.cxx
// Created:	Thu Oct 26 20:10:02 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>

#ifdef WNT
#include <io.h>
#else
#include <unistd.h>
#endif

#include <WOKTools_Messages.hxx>

#include <WOKUtils_Param.hxx>
#include <WOKUtils_Path.hxx>

#include <WOKernel_Session.hxx>
#include <WOKernel_DevUnit.hxx>
#include <WOKernel_FileType.hxx>
#include <WOKernel_FileTypeBase.hxx>
#include <WOKernel_File.hxx>
#include <WOKernel_HSequenceOfFile.hxx>
#include <WOKernel_Locator.hxx>

#include <WOKBuilder_Include.hxx>

#include <WOKMake_InputFile.hxx>
#include <WOKMake_OutputFile.hxx>
#include <WOKMake_AdmFileTypes.hxx>

#include <WOKStep_Include.ixx>

#ifdef WNT
# include <tchar.h>
# include <WOKNT_WNT_BREAK.hxx>

extern "C" int __declspec( dllimport ) wokCP ( int, char** );
extern "C" int __declspec( dllimport ) wokCMP ( int, char** );

#endif  // WNT

//=======================================================================
//function : WOKStep_Include
//purpose  : 
//=======================================================================
 WOKStep_Include::WOKStep_Include(const Handle(WOKMake_BuildProcess)&     abp,
				  const Handle(WOKernel_DevUnit)&         aunit, 
				  const Handle(TCollection_HAsciiString)& acode, 
				  const Standard_Boolean checked, 
				  const Standard_Boolean hidden)
: WOKMake_Step(abp, aunit,  acode, checked, hidden)
{
}

//=======================================================================
//Author   : Jean Gautier (jga)
//function : AdmFileType
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKStep_Include::AdmFileType() const
{
  static Handle(TCollection_HAsciiString) result = new TCollection_HAsciiString((char*)DBADMFILE);
  return result; 
}


//=======================================================================
//Author   : Jean Gautier (jga)
//function : OutputDirTypeName
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKStep_Include::OutputDirTypeName() const
{
  static Handle(TCollection_HAsciiString) result = new TCollection_HAsciiString((char*)DBTMPDIR);
  return result; 
}


//=======================================================================
//function : HandleInputFile
//purpose  : 
//=======================================================================
Standard_Boolean WOKStep_Include::HandleInputFile(const Handle(WOKMake_InputFile)& infile)
{
  Handle(WOKBuilder_Entity) result;
  Handle(WOKUtils_Path)     apath;

  if(!infile->File().IsNull())
    {
      apath = infile->File()->Path();
      switch(apath->Extension())
	{
	case WOKUtils_HFile:  
	case WOKUtils_HXXFile:
	case WOKUtils_LXXFile:
	case WOKUtils_GXXFile:
	case WOKUtils_IDLFile:
	case WOKUtils_INCFile:
	  result = new WOKBuilder_Include(apath); break;
	default:  
	  return Standard_False;
	}
      infile->SetBuilderEntity(result);
      infile->SetDirectFlag(Standard_True);
      return Standard_True;
    }
  else
    {
      return Standard_False;
    }
}

//=======================================================================
//function : Execute
//purpose  : 
//=======================================================================
void WOKStep_Include::Execute(const Handle(WOKMake_HSequenceOfInputFile)& tobuild)
{
  Standard_Integer i;
  Handle(WOKernel_File) incfile;
  Handle(WOKernel_File) pubincfile;
  Handle(WOKernel_FileType) sourcetype = Unit()->FileTypeBase()->Type("source");
  Handle(WOKernel_FileType) pubinctype = Unit()->FileTypeBase()->Type("pubinclude");

  Handle(WOKMake_InputFile) infile;
  
  for(i=1; i<=tobuild->Length(); i++)
    {
#ifdef WNT
      _TEST_BREAK();
#endif  // WNT
      infile = tobuild->Value(i);
      
      // include de type source local au wb
      pubincfile = new WOKernel_File(infile->File()->Name(), Unit(), pubinctype);
      pubincfile->GetPath();

      if(infile->File()->Nesting()->IsSameString(Unit()->FullName()))
	{
	  if(pubincfile->Path()->Exists())
	    {
	      pubincfile->Path()->RemoveFile();
	    }

#ifndef WNT
	  symlink(infile->File()->Path()->Name()->ToCString(), pubincfile->Path()->Name()->ToCString());
#else
	  Standard_CString CmpArgs[4];

 	  CmpArgs[0] = "wokCMP";
          CmpArgs[1] = infile->File()->Path()->Name()->ToCString();
          CmpArgs[2] = pubincfile->Path()->Name()->ToCString();
	  if(wokCMP(3, CmpArgs)) 
	    {
	      Standard_CString CpArgs[4];
	      
	      CpArgs[0] = "wokCP";
	      CpArgs[1] = infile->File()->Path()->Name()->ToCString();
	      CpArgs[2] = pubincfile->Path()->Name()->ToCString();
	      wokCP(3, CpArgs);
	    }
#endif
	}
      else
       {
	 pubincfile->Path()->RemoveFile();
       }

      
      pubincfile = Locator()->Locate(Unit()->Name(), pubinctype->Name(), infile->File()->Name());

      if(!pubincfile.IsNull())
	{
	  Handle(WOKMake_OutputFile) outfile = new WOKMake_OutputFile(pubincfile->LocatorName(), pubincfile, 
								      Handle(WOKBuilder_Entity)(), pubincfile->Path());
	  outfile->SetProduction();
	  outfile->SetLocateFlag(Standard_True);
	  
	  AddExecDepItem(infile, outfile, Standard_True);
	}
    }

  SetSucceeded();
  return;
}

