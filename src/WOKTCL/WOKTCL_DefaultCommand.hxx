// File:	WOKTCL_DefaultCommand.hxx
// Created:	Mon Oct 28 17:28:26 1996
// Author:	Jean GAUTIER
//		<jga@cobrax.paris1.matra-dtv.fr>


#ifndef WOKTCL_DefaultCommand_HeaderFile
#define WOKTCL_DefaultCommand_HeaderFile


struct CData {
  CData(WOKAPI_APICommand ff, Handle(WOKTCL_Interpretor) ii) : f(ff), i(ii) {}
  WOKAPI_APICommand   f;
  Handle(WOKTCL_Interpretor) i;
};


Standard_Integer DefaultCommand(ClientData , Tcl_Interp *, 
				Standard_Integer , char* []);

void DefaultCommandDelete (ClientData );

#endif
