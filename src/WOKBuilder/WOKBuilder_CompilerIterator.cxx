// File:	WOKBuilder_CompilerIterator.cxx
// Created:	Fri Oct 13 17:29:00 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>


#include <WOKBuilder_CompilerIterator.ixx>

#include <WOKTools_Messages.hxx>
#include <WOKUtils_Path.hxx>
#include <WOKUtils_HSequenceOfPath.hxx>

#include <WOKBuilder_Compilable.hxx>
#include <WOKBuilder_Compiler.hxx>

//=======================================================================
//Author   : Jean Gautier (jga)
//function : WOKBuilder_CompilerIterator
//purpose  : 
//=======================================================================
WOKBuilder_CompilerIterator::WOKBuilder_CompilerIterator(const Handle(TCollection_HAsciiString)& agroup,
							 const WOKUtils_Param& params)
: WOKBuilder_ToolInShellIterator(agroup, params)
{
}


//=======================================================================
//function : WOKBuilder_CompilerIterator
//purpose  : 
//=======================================================================
WOKBuilder_CompilerIterator::WOKBuilder_CompilerIterator(const Handle(WOKBuilder_HSequenceOfToolInShell)& compilers)
  : WOKBuilder_ToolInShellIterator(compilers)
{
}

//=======================================================================
//function : WOKBuilder_CompilerIterator
//purpose  : 
//=======================================================================
WOKBuilder_CompilerIterator::WOKBuilder_CompilerIterator(const Handle(TCollection_HAsciiString)& agroup,
							 const Handle(WOKUtils_Shell)& ashell,
							 const Handle(WOKUtils_Path)& outdir,
							 const Handle(WOKUtils_HSequenceOfPath)& incdirs,
							 const Handle(WOKUtils_HSequenceOfPath)& dbdirs,
							 const WOKUtils_Param& params)
  : WOKBuilder_ToolInShellIterator(agroup,ashell,outdir,params), myincdirs(incdirs), mydbdirs(dbdirs)
{
}

//=======================================================================
//function : WOKBuilder_CompilerIterator
//purpose  : 
//=======================================================================
void WOKBuilder_CompilerIterator::Init(const Handle(WOKUtils_Shell)& ashell,
				       const Handle(WOKUtils_Path)& outdir,
				       const Handle(WOKUtils_HSequenceOfPath)& incdirs,
				       const Handle(WOKUtils_HSequenceOfPath)& dbdirs)
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString) optline;

  WOKBuilder_ToolInShellIterator::Init(ashell,outdir);
  
  myincdirs = incdirs;
  mydbdirs  = dbdirs;
  
  Handle(WOKBuilder_HSequenceOfToolInShell) tools = Tools();

  if(!tools.IsNull())
    {
      for(i=1; i<=tools->Length(); i++)
	{
	  Handle(WOKBuilder_Compiler) acompiler = Handle(WOKBuilder_Compiler)::DownCast(tools->Value(i));
	  
	  if(!acompiler.IsNull())
	    {
	      acompiler->SetIncludeDirectories(myincdirs);
	      acompiler->SetDatabaseDirectories(mydbdirs);
	    }
	
	  optline = acompiler->OptionLine();
	  
	  if(optline.IsNull())
	    {
	      ErrorMsg << "WOKBuilder_CompilerIterator::Init"
		<< "Could not eval compiler " << acompiler->Name() << " options" << endm;
	      return;
	    }
	  
	  InfoMsg << "WOKBuilder_CompilerIterator::Init" << optline << endm;
	}
    }
}


//=======================================================================
//Author   : Jean Gautier (jga)
//function : GetTool
//purpose  : 
//=======================================================================
Handle(WOKBuilder_ToolInShell) WOKBuilder_CompilerIterator::GetTool(const Handle(TCollection_HAsciiString)& aname, 
									      const WOKUtils_Param& params) const
{
  return new WOKBuilder_Compiler(aname,params);
}

//=======================================================================
//function : Execute
//purpose  : 
//=======================================================================
WOKBuilder_BuildStatus WOKBuilder_CompilerIterator::Execute(const Handle(WOKBuilder_Compilable)& acompilable)  
{
  Handle(WOKBuilder_Compiler) acompiler;
  WOKBuilder_BuildStatus status;

  myproduction.Nullify();

  acompiler = Handle(WOKBuilder_Compiler)::DownCast(AppropriateTool(acompilable));

  if(acompiler.IsNull())
    {
      ErrorMsg << "WOKBuilder_CompilerIterator::Execute" 
	<< "Could not find appropriate Compiler for " << acompilable->Path()->Name() << endm;
      return WOKBuilder_Failed;
    }

  // setter le .compilable
  acompiler->SetCompilable(acompilable);

  status = acompiler->Execute();  

  if(status == WOKBuilder_Success)
    {
      myproduction = acompiler->Produces();

      if (  !acompiler -> myCmdLine.IsNull ()  ) myCmdLine = new TCollection_HAsciiString ( acompiler -> myCmdLine );

    }
  return status;
}
