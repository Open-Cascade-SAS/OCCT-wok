// File:	WOKTools_Error.cxx
// Created:	Wed Jun 28 20:22:48 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>

#ifndef WNT
#include <stream.h>
#endif

#include <WOKTools_Error.ixx>

Standard_EXPORT WOKTools_Error ErrorMsg;

WOKTools_Error::WOKTools_Error() : WOKTools_Message("WOK_ERROR", "Error   : ")
{
  Set();
}


Standard_Character WOKTools_Error::Code() const 
{return 'E';}
