// File:	WOKStep_MSStep.cxx
// Created:	Tue Nov 14 19:16:15 1995
// Author:	Jean GAUTIER
//		<jga@cobrax>



#include <WOKTools_Messages.hxx>

#include <WOKernel_FileTypeBase.hxx>

#include <WOKBuilder_MSEntity.hxx>


#include <WOKMake_InputFile.hxx>

#include <WOKStep_MSStep.ixx>

//=======================================================================
//function : WOKStep_MSStep
//purpose  : 
//=======================================================================
 WOKStep_MSStep::WOKStep_MSStep(const Handle(WOKMake_BuildProcess)& abp,
				const Handle(WOKernel_DevUnit)& aunit, 
				const Handle(TCollection_HAsciiString)& acode, 
				const Standard_Boolean checked, 
				const Standard_Boolean hidden)
: WOKMake_Step(abp,aunit, acode, checked, hidden)
{
}

//=======================================================================
//function : BuilderEntity
//purpose  : 
//=======================================================================
Handle(WOKBuilder_Entity) WOKStep_MSStep::BuilderEntity(const Handle(WOKernel_File)& infile) const
{
  Handle(WOKBuilder_Entity) entity;
  
  if(myinflow.Contains(infile->LocatorName())) 
    {
      entity = myinflow.FindFromKey(infile->LocatorName())->BuilderEntity();
      if(!entity.IsNull()) return entity;
    }
  if(!strcmp(infile->TypeName()->ToCString(),"msentity"))
    {
      entity = new WOKBuilder_MSEntity(infile->Name());
      entity->SetPath(infile->Path());
      return entity;
    }
  return entity;
}

