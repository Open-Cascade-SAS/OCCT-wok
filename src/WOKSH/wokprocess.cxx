// File:	woksh.cxx<2>
// Created:	Tue Aug  1 23:26:26 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>

#ifdef WNT
# ifdef TCL_VERSION_75
#  pragma comment( lib, "tcl75.lib" )
#  pragma message( "Information: tcl75.lib is using as TCL library" )
#  include <tcl75.h>
# elif defined( TCL_VERSION_76 )
#  pragma comment( lib, "tcl76.lib" )
#  pragma message( "Information: tcl76.lib is using as TCL library" )
# else
#  pragma comment( lib, "tcl76i.lib" )
#  pragma message( "Information: tcl76i.lib is using as TCL library" )
# endif  // TCL75
#endif  // WNT

#include <tcl.h>


#include <Standard_ErrorHandler.hxx>
#include <Standard_Failure.hxx>

#include <OSD.hxx>

#include <WOKTools_Messages.hxx>
#include <WOKTools_Return.hxx>

#ifdef WNT
#include <WOKUtils_ShellManager.hxx>
#define WOKUtils_ProcessManager WOKUtils_ShellManager
#else
#include <WOKUtils_Signal.hxx>
#include <WOKUtils_SigHandler.hxx>
#include <WOKUtils_ProcessManager.hxx>
#endif
#include <WOKUtils_Trigger.hxx>

#include <WOKAPI_Session.hxx>
#include <WOKAPI_Command.hxx>

#include <WOKTclTools_Package.hxx>

#include <WOKTCL_Interpretor.hxx>

#include <WOKTCL_TriggerHandler.hxx>

extern Standard_IMPORT Handle(WOKTclTools_Interpretor) CurrentInterp;
//Standard_IMPORT Handle(WOKTclTools_Interpretor) CurrentInterp;

#ifdef WNT
# ifdef _DEBUG
extern "C" void _debug_break ( char* );
# endif  // _DEBUG
# define WOK_EXPORT __declspec( dllexport )
#else
# define WOK_EXPORT
#endif  // WNT

extern "C" WOK_EXPORT void Wok_ExitHandler(void *); 
extern "C" WOK_EXPORT int  Wok_Init(WOKTclTools_PInterp );

void Wok_ExitHandler(void *) 
{
  WOKUtils_ProcessManager::KillAll();
}


int main(int argc, char **argv)
{
#if defined( WNT ) && defined( _DEBUG )
  _debug_break ( "main" );
#endif  // WNT && _DEBUG

  WOKTclTools_PInterp interp  = Tcl_CreateInterp();
  
  if(WOKTclTools_Interpretor::Current().IsNull())
    {
      CurrentInterp = new WOKTCL_Interpretor;
      CurrentInterp->Set(interp);
    }
  else
    {
      if(WOKTclTools_Interpretor::Current()->Interp() != interp)
	{
	   CurrentInterp = new WOKTCL_Interpretor;
	   CurrentInterp->Set(interp);
	}
    }

  WOKTclTools_Package tcl(CurrentInterp, "Tcl", "7.5");
  
  tcl.Require();
  
  OSD::SetSignal();                  //==== Armed the signals. =============
#ifndef WNT
  WOKUtils_Signal::Arm(WOKUtils_SIGINT,    (WOKUtils_SigHandler) NULL);
#endif //WNT

  Handle(WOKTCL_Interpretor) WOKInter = Handle(WOKTCL_Interpretor)::DownCast(CurrentInterp);

  if(WOKInter.IsNull())
    {
      WOKInter = new WOKTCL_Interpretor(interp);
    }

  if(CurrentInterp->EndMessageProc() != NULL)
    WOKInter->SetEndMessageProc(CurrentInterp->EndMessageProc());

  CurrentInterp = WOKInter;

  WOKUtils_ProcessManager::Arm();

  WOKUtils_Trigger::SetTriggerHandler(WOKTCL_TriggerHandler);

  WOKInter->AddExitHandler(Wok_ExitHandler);

  try {
    WOKTools_Return returns;
    
    WOKInter->ChangeSession().Open();

    WOKAPI_Command::WorkbenchProcess(WOKInter->Session(), argc, argv,  returns);

    WOKInter->TreatReturn(returns);
    
  }
  catch(Standard_Failure) {
    Handle(Standard_Failure) E = Standard_Failure::Caught();
    strstream astream;
    astream << E << ends;
    ErrorMsg << "WOKTCL_AppInit" << "Exception was raised : " << astream.str() << endm;
    WOKUtils_ProcessManager::UnArm();
    return TCL_ERROR;
  }

  WOKUtils_ProcessManager::UnArm();


  return 0;
}

