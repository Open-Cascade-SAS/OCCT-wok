#include <WOKBuilder_DLLinker.ixx>

#include <WOKBuilder_ImportLibrary.hxx>
#include <WOKBuilder_SharedLibrary.hxx>
#include <WOKBuilder_ExportLibrary.hxx>
#include <WOKBuilder_HSequenceOfEntity.hxx>

#include <WOKTools_Messages.hxx>

#include <WOKUtils_Path.hxx>

#include <OSD_Environment.hxx>

WOKBuilder_DLLinker::WOKBuilder_DLLinker(const Handle(TCollection_HAsciiString)& aName,
					 const WOKUtils_Param&                   aParams)
: WOKBuilder_WNTLinker(aName,aParams) 
{
}  // end constructor

Handle(TCollection_HAsciiString) WOKBuilder_DLLinker::EvalHeader()
{
  OSD_Environment env("WOK_LINKER");
  Handle(TCollection_HAsciiString) retVal;
  TCollection_AsciiString val = env.Value();

  if(!env.Failed()) 
    {
      retVal = new TCollection_HAsciiString ( val );

      InfoMsg << "WOKBuilder_DLLinker :: EvalHeader"
	<< '\'' << retVal << "' is using" << endm;
    } 
  else
    retVal = EvalToolTemplate ( "LinkerHeaderDLL" );
  return retVal;
}


Handle(TCollection_HAsciiString) WOKBuilder_DLLinker::EvalCFExt()
{
  return EvalToolParameter ( "LinkerCFExtDLL" );
} 

Handle(TCollection_HAsciiString) WOKBuilder_DLLinker::EvalFooter()
{
  Handle(WOKBuilder_Entity)        outEnt[4];
  Handle(TCollection_HAsciiString) tmp;
  Handle(TCollection_HAsciiString) retVal = EvalToolParameter("LinkerOutput");
  Standard_Boolean                 fDebug;

  //fDebug = Params().Value("%DebugMode")->IsSameString(new TCollection_HAsciiString("True")) ? Standard_True : Standard_False;
 
  tmp = EvalToolTemplate("LinkerDLL");

  outEnt[0] = new WOKBuilder_SharedLibrary(new WOKUtils_Path(tmp));

  retVal->AssignCat(tmp );
  retVal->AssignCat(EvalToolParameter("LinkerImplib"));

  tmp = EvalToolTemplate("LinkerIMP");

  outEnt[1] = new WOKBuilder_ImportLibrary(new WOKUtils_Path(tmp));

  retVal->AssignCat(tmp);

  outEnt[2] = new WOKBuilder_ExportLibrary(new WOKUtils_Path(EvalToolTemplate("LinkerEXP")));

  //if (fDebug) {

  retVal -> AssignCat (  EvalToolParameter ( "LinkerPDBOption" )  );
  tmp = EvalToolTemplate ( "LinkerPDB" );
  retVal -> AssignCat ( tmp );
  outEnt[3] = new WOKBuilder_SharedLibrary(new WOKUtils_Path(tmp));
  //} 

  SetProduction(new WOKBuilder_HSequenceOfEntity());

  Produces()->Append(outEnt[0]);
  Produces()->Append(outEnt[1]);
  Produces()->Append(outEnt[2]);

  //if( fDebug ) 
  Produces()->Append(outEnt[3]);
  return retVal;
}
