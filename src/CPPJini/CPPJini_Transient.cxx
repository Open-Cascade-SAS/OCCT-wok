#define CPPJini_CREATE_EMPTY_JAVA_CONSTRUCTOR 0
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

#include <MS_MemberMet.hxx>
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

extern Standard_Boolean CPPJini_HasComplete (
                         const Handle( TCollection_HAsciiString )&,
                         Handle( TCollection_HAsciiString       )&,
                         Standard_Boolean&
                        );

extern Standard_Boolean CPPJini_HasIncomplete (
                         const Handle( TCollection_HAsciiString )&,
                         Handle( TCollection_HAsciiString       )&,
                         Standard_Boolean&
                        );

extern Standard_Boolean CPPJini_HasSemicomplete (
                         const Handle( TCollection_HAsciiString )&,
                         Handle( TCollection_HAsciiString       )&,
                         Standard_Boolean&
                        );

void CPPJini_MethodUsedTypes(const Handle(MS_MetaSchema)& aMeta,
			       const Handle(MS_Method)& aMethod,
			       const Handle(TColStd_HSequenceOfHAsciiString)& List,
			       const Handle(TColStd_HSequenceOfHAsciiString)& Incp);

// Extraction of a transient handle
//

// Extraction of .cxx for handled object
//
void CPPJini_TransientDerivated(const Handle(MS_MetaSchema)& aMeta,
				  const Handle(EDL_API)& api,
				  const Handle(MS_Class)& aClass,			    
				  const Handle(TColStd_HSequenceOfHAsciiString)& outfile,
				  const Handle(TColStd_HSequenceOfHAsciiString)& inclist,
				  const Handle(TColStd_HSequenceOfHAsciiString)& supplement,
				  const ExtractionType MustBeComplete)
{
  Handle(TCollection_HAsciiString)        publics    = new TCollection_HAsciiString;
  Standard_Integer                        i;
  
  // the name must be <Inter>_<Pack>_<Class>
  //
  api->AddVariable("%Class",aClass->FullName()->ToCString());

  if (MustBeComplete != CPPJini_INCOMPLETE) {
    for (i = 1; i <= inclist->Length(); i++) {
      if (!inclist->Value(i)->IsSameString(aClass->FullName())) {
	api->AddVariable("%IClass",inclist->Value(i)->ToCString());
	api->Apply("%Includes","IncludeCPlus");
	publics->AssignCat(api->GetVariableValue("%Includes"));
      }
    }
  }

  api->AddVariable("%Includes",publics->ToCString());
  publics->Clear();

  if (MustBeComplete != CPPJini_INCOMPLETE) {
    for (i = 1; i <= supplement->Length(); i++) {
      publics->AssignCat(supplement->Value(i));
    }
  }

  api->AddVariable("%Methods",publics->ToCString());
  publics->Clear();

  // we create the inheritance
  //
  if (aClass->FullName()->IsSameString(MS::GetTransientRootName())) {
    api->AddVariable("%Inherits",CPPJini_GetFullJavaType(CPPJini_TransientRootName())->ToCString());
  }
  else {
    api->AddVariable("%Inherits",CPPJini_GetFullJavaType(aClass->GetInheritsNames()->Value(1))->ToCString());
  }

  api->AddVariable("%Class",aClass->FullName()->ToCString());

  api->Apply("%outClass","TransientClassClientCXX");

  // we write the .cxx of this class
  //
  Handle(TCollection_HAsciiString) aFile = new TCollection_HAsciiString(api->GetVariableValue("%FullPath"));
  
  aFile->AssignCat(CPPJini_InterfaceName);
  aFile->AssignCat("_");
  aFile->AssignCat(aClass->FullName());
  aFile->AssignCat("_java.cxx");
  
  CPPJini_WriteFile(api,aFile,"%outClass");
  
  outfile->Append(aFile);
}


// Extraction of a transient class (inst or std)
//
void CPPJini_TransientClass(const Handle(MS_MetaSchema)& aMeta,
			    const Handle(EDL_API)& api,
			    const Handle(MS_Class)& aClass,
			    const Handle(TColStd_HSequenceOfHAsciiString)& outfile,
			    const ExtractionType MustBeComplete,
			    const Handle(MS_HSequenceOfMemberMet)& theMetSeq)
{
  Handle(MS_StdClass) theClass = Handle(MS_StdClass)::DownCast(aClass);

  if (!theClass.IsNull()) {
    Standard_Integer                        i;
    Handle(MS_HSequenceOfMemberMet)         methods;
    Handle(TCollection_HAsciiString)        publics             = new TCollection_HAsciiString;
    Handle(TCollection_HAsciiString)        SuppMethod          = new TCollection_HAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) Supplement          = new TColStd_HSequenceOfHAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) List = new TColStd_HSequenceOfHAsciiString;
    Handle(TColStd_HSequenceOfHAsciiString) incp = new TColStd_HSequenceOfHAsciiString;

    // we create the inheritance
    //
    if (theClass->FullName()->IsSameString(MS::GetTransientRootName())) return;

    api->AddVariable("%Class",theClass->FullName()->ToCString());

    if (MustBeComplete == CPPJini_SEMICOMPLETE) {
      methods = theMetSeq;
    }
    else if (MustBeComplete == CPPJini_COMPLETE){
      methods = theClass->GetMethods();
    }
#if CPPJini_CREATE_EMPTY_JAVA_CONSTRUCTOR
    Standard_Boolean mustCreateEmptyConst = !CPPJini_HaveEmptyConstructor(aMeta,theClass->FullName(),methods);
#endif
    if (MustBeComplete != CPPJini_INCOMPLETE) {
      if (methods->Length() > 0)  {
	CPPJini_DataMapOfAsciiStringInteger mapnames;
	
	TColStd_Array1OfInteger theindexes(1,methods->Length());
	theindexes.Init(0);
	
	
	for (i = 1; i <= methods->Length(); i++) {
	  CPPJini_CheckMethod(i,methods->Value(i)->Name(),mapnames,theindexes);
	}
	
	for (i = 1; i <= methods->Length(); i++) {
	  CPPJini_BuildMethod(aMeta,api,theClass->FullName(),methods->Value(i),methods->Value(i)->Name(),theindexes(i));
	  if (!api->GetVariableValue("%Method")->IsSameString(CPPJini_ErrorArgument)) {
	    
	    if ((theClass->Deferred() && methods->Value(i)->IsKind(STANDARD_TYPE(MS_Construc))) 
		|| methods->Value(i)->IsProtected() 
		|| methods->Value(i)->Private())  {
	      // nothing
	    } 
	    else {
	      CPPJini_MethodUsedTypes(aMeta,methods->Value(i),List,incp);
	      publics->AssignCat(api->GetVariableValue(VJMethod));
	      CPPJini_MethodBuilder(aMeta,api,aClass->FullName(),methods->Value(i),methods->Value(i)->Name(),theindexes(i));
	      Supplement->Append(api->GetVariableValue(VJMethod));
	    }
	  }
	}
      }
    }
#if CPPJini_CREATE_EMPTY_JAVA_CONSTRUCTOR
    if (mustCreateEmptyConst) {
      api->Apply(VJMethod,"EmptyConstructorHeader");
      publics->AssignCat(api->GetVariableValue(VJMethod));
    }
#endif
    api->AddVariable("%Methods",publics->ToCString());

    publics->Clear();

    if (MustBeComplete != CPPJini_INCOMPLETE) {
      
      for (i = 1; i <= List->Length(); i++) {
	if (!List->Value(i)->IsSameString(theClass->FullName())) {
	  api->AddVariable("%IClass",List->Value(i)->ToCString());
	  if (CPPJini_IsCasType(List->Value(i))) {
	    api->Apply("%Includes","IncludeJCas");
	  }
	  else {
            Handle( TCollection_HAsciiString ) aClt;
            Standard_Boolean                   fDup;
            Standard_Boolean                   fPush = Standard_False;

            if (  CPPJini_HasComplete (
                   List -> Value ( i ), aClt, fDup
                  ) ||
                  CPPJini_HasIncomplete (
                   List -> Value ( i ), aClt, fDup
                  ) ||
                  CPPJini_HasSemicomplete (
                   List -> Value ( i ), aClt, fDup
                  )
            ) {

             fPush = Standard_True;
             api -> AddVariable (  "%Interface", aClt -> ToCString ()  );

            }  // end if

             api->Apply("%Includes","Include");

            if ( fPush )

             api -> AddVariable (
                     "%Interface", CPPJini_InterfaceName -> ToCString ()
                    );
	  }
	  publics->AssignCat(api->GetVariableValue("%Includes"));
	}
      }
      
      
      for (i = 1; i <= incp->Length(); i++) {
	if (!incp->Value(i)->IsSameString(theClass->FullName())) {
	  api->AddVariable("%IClass",incp->Value(i)->ToCString());
	  if (CPPJini_IsCasType(incp->Value(i))) {
	    api->Apply("%Includes","ShortDecJCas");
	  }
	  else {
            Handle( TCollection_HAsciiString ) aClt;
            Standard_Boolean                   fDup;
            Standard_Boolean                   fPush = Standard_False;

            if (  CPPJini_HasComplete (
                   List -> Value ( i ), aClt, fDup
                  ) ||
                  CPPJini_HasIncomplete (
                   List -> Value ( i ), aClt, fDup
                  ) ||
                  CPPJini_HasSemicomplete (
                   List -> Value ( i ), aClt, fDup
                  )
            ) {

             fPush = Standard_True;
             api -> AddVariable (  "%Interface", aClt -> ToCString ()  );

            }  // end if

	    api->Apply("%Includes","ShortDec");

            if ( fPush )

             api -> AddVariable (
                     "%Interface", CPPJini_InterfaceName -> ToCString ()
                    );
	  }
	  publics->AssignCat(api->GetVariableValue("%Includes"));
	}
      }
    }

    api->AddVariable("%Includes",publics->ToCString());

    // we create the inheritance
    //
    Handle( TCollection_HAsciiString ) aClt;
    Standard_Boolean                   fDup;

    if (  CPPJini_HasComplete (
           theClass -> GetInheritsNames ()-> Value ( 1 ), aClt, fDup
          ) ||
          CPPJini_HasIncomplete (
           theClass -> GetInheritsNames ()-> Value ( 1 ), aClt, fDup
          ) ||
          CPPJini_HasSemicomplete (
           theClass -> GetInheritsNames () -> Value ( 1 ), aClt, fDup
          )
    ) {

     aClt -> AssignCat ( "." );
     aClt -> AssignCat (  theClass -> GetInheritsNames () -> Value ( 1 )  );
     api -> AddVariable (  "%Inherits", aClt -> ToCString ()  );

   } else

     api->AddVariable("%Inherits",CPPJini_GetFullJavaType(theClass->GetInheritsNames()->Value(1))->ToCString());

    api->AddVariable("%Class",theClass->FullName()->ToCString());

    api->Apply("%outClass","TransientClassClientJAVA");

    // we write the .java of this class
    //
    Handle(TCollection_HAsciiString) aFile = new TCollection_HAsciiString(api->GetVariableValue("%FullPath"));

    aFile->AssignCat(theClass->FullName());
    aFile->AssignCat(".java");

    CPPJini_WriteFile(api,aFile,"%outClass");

    outfile->Append(aFile);


    CPPJini_TransientDerivated(aMeta,api,aClass,outfile,incp,Supplement,MustBeComplete);
  }
  else {
    ErrorMsg << "CPPJini" << "CPPJini_TransientClass - the class is NULL..." << endm;
    Standard_NoSuchObject::Raise();
  }
}

