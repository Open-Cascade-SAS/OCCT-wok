
#include <WOKUnix_Signal.ixx>


#include <stdlib.h>
#include <signal.h>

#ifdef LIN
#include <bits/sigset.h>
#include <signal.h>
#elif !defined(HPUX)
#include <siginfo.h>
#endif

//=======================================================================
//function : WOKUnix_Signal
//purpose  : 
//=======================================================================
 WOKUnix_Signal::WOKUnix_Signal()
{
  isarmed = Standard_False;
}

//=======================================================================
//function : WOKUnix_Signal
//purpose  : 
//=======================================================================
 WOKUnix_Signal::WOKUnix_Signal(const WOKUnix_Signals asig)
{
  mysig = asig;
  isarmed = Standard_False;
}

//=======================================================================
//function : Set
//purpose  : 
//=======================================================================
void WOKUnix_Signal::Set(const WOKUnix_Signals asig)
{
  mysig = asig;
  isarmed = Standard_False;
}

//=======================================================================
//function : Arm
//purpose  : 
//=======================================================================
void WOKUnix_Signal::Arm(const WOKUnix_SigHandler& ahandler)
{
  struct sigaction act, oact;
  int              stat;

  //==== Save the old Signale Handler, and set the new one ===================

  if(ahandler == NULL)
    {
      act.sa_handler =  (WOKUnix_SigHandler) SIG_DFL;
    }
  else
    {
      act.sa_handler =  (WOKUnix_SigHandler) ahandler;
    }
#ifdef SOLARIS
  act.sa_mask.__sigbits[0]    = 0;
  act.sa_mask.__sigbits[1]    = 0;
  act.sa_mask.__sigbits[2]    = 0;
  act.sa_mask.__sigbits[3]    = 0;
  act.sa_flags                = SA_RESTART;
#elif HPUX
  act.sa_mask.sigset[0]    = 0;
  act.sa_mask.sigset[1]    = 0;
  act.sa_mask.sigset[2]    = 0;
  act.sa_mask.sigset[3]    = 0;
  act.sa_mask.sigset[4]    = 0;
  act.sa_mask.sigset[5]    = 0;
  act.sa_mask.sigset[6]    = 0;
  act.sa_mask.sigset[7]    = 0;
  act.sa_flags   = 0;
#elif IRIX
  act.sa_mask.__sigbits[0]      = 0;
  act.sa_mask.__sigbits[1]      = 0;
  act.sa_mask.__sigbits[2]      = 0;
  act.sa_mask.__sigbits[3]      = 0;
  act.sa_flags             = 0;
#elif defined(LIN)
  sigemptyset(&act.sa_mask) ;
  act.sa_flags   = 0;
#else
  act.sa_mask    = 0;
  act.sa_flags   = 0;
#endif

  //==== Always detected the signal "SIGFPE" =================================
  stat = sigaction(WOKUnix_Signal::GetSig(mysig),&act,&oact);   // ...... floating point exception 
  if (stat) {
     cerr << "sigaction does not work !!! KO " << endl;
     perror("sigaction ");
  }
}

//=======================================================================
//function : Arm
//purpose  : 
//=======================================================================
void WOKUnix_Signal::Arm(const WOKUnix_Signals asig, const WOKUnix_SigHandler& ahandler)
{
  WOKUnix_Signal thesig(asig);

  thesig.Arm(ahandler);
}

int WOKUnix_Signal::GetSig(const WOKUnix_Signals asig) 
{
  switch (asig)
    {
    case WOKUnix_SIGPIPE  : return SIGPIPE;
    case WOKUnix_SIGHUP   : return SIGHUP;
    case WOKUnix_SIGINT   : return SIGINT;
    case WOKUnix_SIGQUIT  : return SIGQUIT;
    case WOKUnix_SIGILL   : return SIGILL;
    case WOKUnix_SIGKILL  : return SIGKILL;
    case WOKUnix_SIGBUS   : return SIGBUS;
    case WOKUnix_SIGSEGV  : return SIGSEGV;
    case WOKUnix_SIGCHILD : return SIGCLD;
    }
}
