// CLE
//    
// 10/1995
//
#include <MS.hxx>

#include <EDL_API.hxx>

#include <MS_MetaSchema.hxx>

#include <MS_Class.hxx>
#include <MS_GenClass.hxx>
#include <MS_InstClass.hxx>
#include <MS_Package.hxx>
#include <MS_Error.hxx>
#include <MS_Imported.hxx>

#include <MS_InstMet.hxx>
#include <MS_ClassMet.hxx>
#include <MS_Construc.hxx>
#include <MS_ExternMet.hxx>
 
#include <MS_Param.hxx>
#include <MS_Field.hxx>
#include <MS_GenType.hxx>
#include <MS_Enum.hxx>
#include <MS_PrimType.hxx>

#include <MS_HSequenceOfMemberMet.hxx>
#include <MS_HSequenceOfExternMet.hxx>
#include <MS_HSequenceOfParam.hxx>
#include <MS_HSequenceOfField.hxx>
#include <MS_HSequenceOfGenType.hxx>
#include <TColStd_HSequenceOfHAsciiString.hxx>
#include <TColStd_HSequenceOfInteger.hxx>

#include <TCollection_HAsciiString.hxx>

#include <Standard_NoSuchObject.hxx>

#include <CPPJini_Define.hxx>
#include <WOKTools_Messages.hxx>
#include <CPPJini_DataMapOfAsciiStringInteger.hxx>
#include <TColStd_Array1OfInteger.hxx>
#include <CPPJini_ExtractionType.hxx>

void CPPJini_MethodUsedTypes(const Handle(MS_MetaSchema)& aMeta,
			       const Handle(MS_Method)& aMethod,
			       const Handle(TColStd_HSequenceOfHAsciiString)& List,
			       const Handle(TColStd_HSequenceOfHAsciiString)& Incp);

//void CPPJini_PackageDerivated(const Handle(MS_MetaSchema)& aMeta,
void CPPJini_PackageDerivated(const Handle(MS_MetaSchema)& ,
			    const Handle(EDL_API)& api,
			    const Handle(MS_Package)& aPackage,			    
			    const Handle(TColStd_HSequenceOfHAsciiString)& outfile,
			    const Handle(TColStd_HSequenceOfHAsciiString)& inclist,
			    const Handle(TColStd_HSequenceOfHAsciiString)& supplement)
{
  Handle(TCollection_HAsciiString)        publics    = new TCollection_HAsciiString;
  Standard_Integer                        i;

  // the name must be <Inter>_<Pack>
  //
  api->AddVariable("%Class",aPackage->Name()->ToCString());

  for (i = 1; i <= inclist->Length(); i++) {
    if (!inclist->Value(i)->IsSameString(aPackage->Name())) {
      api->AddVariable("%IClass",inclist->Value(i)->ToCString());
      api->Apply("%Includes","IncludeCPlus");
      publics->AssignCat(api->GetVariableValue("%Includes"));
    }
  }
  
  api->AddVariable("%Includes",publics->ToCString());
  publics->Clear();

  for (i = 1; i <= supplement->Length(); i++) {
    publics->AssignCat(supplement->Value(i));
  }

  api->AddVariable("%Methods",publics->ToCString());
  publics->Clear();


  api->AddVariable("%Class",aPackage->Name()->ToCString());

  api->Apply("%outClass","PackageClientCXX");

  // we write the .cxx of this class
  //
  Handle(TCollection_HAsciiString) aFile = new TCollection_HAsciiString(api->GetVariableValue("%FullPath"));
  
  aFile->AssignCat(CPPJini_InterfaceName);
  aFile->AssignCat("_");
  aFile->AssignCat(aPackage->Name());
  aFile->AssignCat("_java.cxx");
  
  CPPJini_WriteFile(api,aFile,"%outClass");
  
  outfile->Append(aFile);

}


// Extraction of a package
//
void CPPJini_Package(const Handle(MS_MetaSchema)& aMeta,
		       const Handle(EDL_API)& api,
		       const Handle(MS_Package)& aPackage,
		       const Handle(TColStd_HSequenceOfHAsciiString)& outfile,
		       const CPPJini_ExtractionType mustBeComplete,
		       const Handle(MS_HSequenceOfExternMet)& theMetSeq)
{
  if (!aPackage.IsNull()) {
    Standard_Integer                        i;

    Handle(MS_HSequenceOfExternMet)         methods;
    Handle(TCollection_HAsciiString)        publics    = new TCollection_HAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) Supplement = new TColStd_HSequenceOfHAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) List = new TColStd_HSequenceOfHAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) incp = new TColStd_HSequenceOfHAsciiString;
    

    // the name must be <Inter>_<Pack>
    //
    api->AddVariable("%Class",aPackage->Name()->ToCString());

    if (mustBeComplete == CPPJini_SEMICOMPLETE) {
      methods = theMetSeq;
    }
    else if (mustBeComplete == CPPJini_COMPLETE) {
      methods = aPackage->Methods();
    }

    // extraction of the methods
    //
    if (mustBeComplete != CPPJini_INCOMPLETE) {
      if (methods->Length() > 0)  {
	CPPJini_DataMapOfAsciiStringInteger mapnames;
	
	TColStd_Array1OfInteger theindexes(1,methods->Length());
	theindexes.Init(0);
	
	
	for (i = 1; i <= methods->Length(); i++) {
	  CPPJini_CheckMethod(i,methods->Value(i)->Name(),mapnames,theindexes);
	}
	
	for (i = 1; i <= methods->Length(); i++) {
	  CPPJini_BuildMethod(aMeta,api,aPackage->Name(),methods->Value(i),methods->Value(i)->Name(),theindexes(i));

	  if (!api->GetVariableValue("%Method")->IsSameString(CPPJini_ErrorArgument)) {
	    
	    CPPJini_MethodUsedTypes(aMeta,methods->Value(i),List,incp);
	    publics->AssignCat(api->GetVariableValue(VJMethod));
	    CPPJini_MethodBuilder(aMeta,api,aPackage->Name(),methods->Value(i),methods->Value(i)->Name(),theindexes(i));
	    Supplement->Append(api->GetVariableValue(VJMethod));
	  }
	}
      }
    }

    api->AddVariable("%Methods",publics->ToCString());

    publics->Clear();


    for (i = 1; i <= List->Length(); i++) {
      if (!List->Value(i)->IsSameString(aPackage->Name())) {
	api->AddVariable("%IClass",List->Value(i)->ToCString());
	if (CPPJini_IsCasType(List->Value(i))) {
	  api->Apply("%Includes","IncludeJCas");
	}
	else {
	  api->Apply("%Includes","Include");
	}
	publics->AssignCat(api->GetVariableValue("%Includes"));
      }
    }

    for (i = 1; i <= incp->Length(); i++) {
      if (!incp->Value(i)->IsSameString(aPackage->Name())) {
	api->AddVariable("%IClass",incp->Value(i)->ToCString());
	if (CPPJini_IsCasType(incp->Value(i))) {
	  api->Apply("%Includes","ShortDecJCas");
	}
	else {
	  api->Apply("%Includes","ShortDec");
	}
	publics->AssignCat(api->GetVariableValue("%Includes"));
      }
    }

    api->AddVariable("%Includes",publics->ToCString());

    api->Apply(VJoutClass,"PackageClientJAVA");
    
    // we write the .hxx of this class
    //
    Handle(TCollection_HAsciiString) aFile = new TCollection_HAsciiString(api->GetVariableValue(VJFullPath));

    aFile->AssignCat(aPackage->Name());
    aFile->AssignCat(".java");

    CPPJini_WriteFile(api,aFile,VJoutClass);

    outfile->Append(aFile);

    CPPJini_PackageDerivated(aMeta,api,aPackage,outfile,incp,Supplement);
  }
  else {
    ErrorMsg << "CPPJini" << "CPPJini_Package - the package is NULL..." << endm;
    Standard_NoSuchObject::Raise();
  }
}

