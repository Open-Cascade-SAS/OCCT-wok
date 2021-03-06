// CLE : Extracteur C++ pour CAS.CADE 
//    Matra-Datavision 1995
//
// 10/1995
//
#include <CPPExt.hxx>
#include <EDL_API.hxx>
#include <EDL_Variable.hxx>
#include <WOKTools_Messages.hxx>
#include <MS_ParamWithValue.hxx>
#include <MS_HArray1OfParam.hxx>

// Standard Extractor API : list the EDL files used by this program
//
Handle(TColStd_HSequenceOfHAsciiString) CPP_TemplatesUsed()
{
  Handle(TColStd_HSequenceOfHAsciiString) result = new TColStd_HSequenceOfHAsciiString;

  result->Append(new TCollection_HAsciiString("CPPExt_Template.edl"));
  result->Append(new TCollection_HAsciiString("CPPExt_TemplateOBJY.edl"));
  result->Append(new TCollection_HAsciiString("CPPExt_TemplateCSFDB.edl"));
  result->Append(new TCollection_HAsciiString("CPPExt_TemplateOBJS.edl"));

  return result;
}


Handle(EDL_API)&  CPP_LoadTemplate(const Handle(TColStd_HSequenceOfHAsciiString)& edlsfullpath,
				   const Handle(TCollection_HAsciiString)& outdir,
				   const Standard_CString DBMS)
{
  static Handle(EDL_API)  api = new EDL_API;
  static Standard_Boolean alreadyLoaded = Standard_False;

  api->ClearVariables();

  if (!alreadyLoaded) {
    alreadyLoaded = Standard_True;

    for(Standard_Integer i = 1; i <= edlsfullpath->Length(); i++) {
      api->AddIncludeDirectory(edlsfullpath->Value(i)->ToCString());
    }

    if (api->Execute("CPPExt_Template.edl") != EDL_NORMAL) {
      ErrorMsg() << "CPPExt" << "unable to load : CPPExt_Template.edl" << endm;
      Standard_NoSuchObject::Raise();
    } 
    if (api->Execute("CPPExt_TemplateOBJY.edl") != EDL_NORMAL) {
      ErrorMsg() << "CPPExt" << "unable to load : CPPExt_TemplateOBJY.edl" << endm;
      Standard_NoSuchObject::Raise();
    }
    if (api->Execute("CPPExt_TemplateCSFDB.edl") != EDL_NORMAL) {
      ErrorMsg() << "CPPExt" << "unable to load : CPPExt_TemplateCSFDB.edl" << endm;
      Standard_NoSuchObject::Raise();
    }
    if (api->Execute("CPPExt_TemplateOBJS.edl") != EDL_NORMAL) {
      ErrorMsg() << "CPPExt" << "unable to load : CPPExt_TemplateOBJS.edl" << endm;
      Standard_NoSuchObject::Raise();
    }
  }
  
  // full path of the destination directory
  //
  api->AddVariable(VFullPath,outdir->ToCString());

  // templates for methods extraction
  //
  api->AddVariable(VMethodHeader,"MethodHeader");
  api->AddVariable(VConstructorHeader,"ConstructorHeader");

  // DBMS extraction type
  //
  api->AddVariable("%CPPEXTDBMS",DBMS);

  return api;
}

// write the content of a variable into a file
//
void CPP_WriteFile(const Handle(EDL_API)& api,
		   const Handle(TCollection_HAsciiString)& aFileName,
		   const Standard_CString var)
{
  // ...now we write the result
  //
  api->OpenFile("HTFile",aFileName->ToCString());
  api->WriteFile("HTFile",var);
  api->CloseFile("HTFile");
}


// sort the used types :
//
//    FullList : all the used types 
//    List     : the types that must have a full definition
//    Incp     : the types that only have to be declared
//
void CPP_UsedTypes(const Handle(MS_MetaSchema)& aMeta,
		   const Handle(MS_Common)& aCommon,
		   const Handle(TColStd_HSequenceOfHAsciiString)& List,
		   const Handle(TColStd_HSequenceOfHAsciiString)& Incp)
{
  if (aCommon->IsKind(STANDARD_TYPE(MS_Type))) {
    if (aCommon->IsKind(STANDARD_TYPE(MS_Class))) {
      Handle(MS_Class) aClass = *((Handle(MS_Class)*)&aCommon);
      
      MS::ClassUsedTypes(aMeta,aClass,List,Incp);
    }
  }
}

// build a return, parameter or field type in c++
//  return a <type name> or a Handle_<type name>
//
//=======================================================================
//function : CPP_BuildType
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) CPP_BuildType (const Handle(MS_MetaSchema)&            theMeta,
                                                const Handle(TCollection_HAsciiString)& theTypeName)
{
  if (!theMeta->IsDefined (theTypeName))
  {
    ErrorMsg() << "CPPExt" << "type " << theTypeName << " not defined..." << endm;
    Standard_NoSuchObject::Raise();
    return new TCollection_HAsciiString();
  }

  Handle(MS_Type) aType = theMeta->GetType (theTypeName);
  if (aType->IsKind (STANDARD_TYPE(MS_Alias)))
  {
    Handle(MS_Alias) anAlias = *((Handle(MS_Alias)*)&aType);
    aType = theMeta->GetType (anAlias->DeepType());
  }

  Standard_Boolean isHandle = Standard_False;

  if (aType->IsKind(STANDARD_TYPE(MS_Class)))
  {
    Handle(MS_Class) aClass = *((Handle(MS_Class)*)&aType);
    isHandle = aClass->IsPersistent()
            || aClass->IsTransient();
  }
  else if (aType->IsKind(STANDARD_TYPE(MS_Imported)))
  {
    Handle(MS_Imported) anImported = *((Handle(MS_Imported)*)&aType);
    isHandle = anImported->IsTransient();
  }

  if (isHandle)
  {
    Handle(TCollection_HAsciiString) aResult = new TCollection_HAsciiString();
    aResult->AssignCat ("Handle(");
    aResult->AssignCat (theTypeName);
    aResult->AssignCat (")");
    return aResult;
  }

  return new TCollection_HAsciiString (theTypeName);
}

// Build a c++ field 
//
Handle(TCollection_HAsciiString) CPP_BuildField(const Handle(MS_MetaSchema)& aMeta,
						const Handle(MS_Field)& aField)
{
  Handle(TCollection_HAsciiString)   result = new TCollection_HAsciiString ("  ");
  Handle(MS_Type)                    aType;
  Handle(TColStd_HSequenceOfInteger) dim;
  Standard_Integer                   i;

  result->AssignCat(CPP_BuildType(aMeta,aField->TYpe()));
  result->AssignCat(" ");
  result->AssignCat(aField->Name());

  dim = aField->Dimensions();

  for (i = 1; i <= dim->Length(); i++) {
    result->AssignCat("[");
    result->AssignCat(new TCollection_HAsciiString(dim->Value(i)));
    result->AssignCat("]");
  }  

  result->AssignCat(";\n");

  return result;
}

// Build a parameter list for methods
//    the output is in C++
//
Handle(TCollection_HAsciiString) CPP_BuildParameterList (const Handle(MS_MetaSchema)&     theMeta,
                                                         const Handle(MS_HArray1OfParam)& theSeq,
                                                         const Standard_Boolean           withDefaultValue)
{
  if (theSeq.IsNull())
  {
    return new TCollection_HAsciiString();
  }

  Handle(TCollection_HAsciiString) aResult = new TCollection_HAsciiString();
  for (Standard_Integer aParamIter = 1; aParamIter <= theSeq->Length(); ++aParamIter)
  {
    Handle(MS_Param) aParam = theSeq->Value (aParamIter);
    if (aParamIter > 1)
    {
      aResult->AssignCat (", ");
    }
    if (!aParam->IsOut())
    {
      aResult->AssignCat ("const ");
    }
    if (theMeta->IsDefined (aParam->TypeName()))
    {
      Handle(MS_Type) aType = theMeta->GetType (aParam->TypeName());
      if (aType->IsKind (STANDARD_TYPE(MS_Alias)))
      {
        Handle(MS_Alias)                 anAlias   = *((Handle(MS_Alias)*)&aType);
        Handle(TCollection_HAsciiString) aDeepType = anAlias->DeepType();
        if (!theMeta->IsDefined (aDeepType))
        {
          ErrorMsg() << "CPPExt" << "incomplete alias deep type in method's parameter..." << endm;
          Standard_NoSuchObject::Raise();
          break;
        }
        aType = theMeta->GetType (aDeepType);
      }

      if (aType->IsKind (STANDARD_TYPE(MS_Class)))
      {
        Handle(MS_Class) aClass = *((Handle(MS_Class)*)&aType);
        if (aClass->IsPersistent()
         || aClass->IsTransient())
        {
          aResult->AssignCat ("Handle(");
          aResult->AssignCat (aParam->TypeName());
          aResult->AssignCat (")& ");
          aResult->AssignCat (aParam->Name());
        }
        else
        {
          aResult->AssignCat (aParam->TypeName());
          aResult->AssignCat ("& ");
          aResult->AssignCat (aParam->Name());
        }
      } // CLASS ^
      else if (aType->IsKind (STANDARD_TYPE(MS_Imported)))
      {
        Handle(MS_Imported) anImported = *((Handle(MS_Imported)*)&aType);
        if (anImported->IsTransient())
        {
          aResult->AssignCat ("Handle(");
          aResult->AssignCat (aParam->TypeName());
          aResult->AssignCat (")& ");
          aResult->AssignCat (aParam->Name());
        }
        else
        {
          aResult->AssignCat (aParam->TypeName());
          aResult->AssignCat ("& ");
          aResult->AssignCat (aParam->Name());
        }
      }
      else if (aType->IsKind (STANDARD_TYPE(MS_Pointer))
            || aParam->IsItem()
            || aParam->IsOut())
      {
        aResult->AssignCat (aParam->TypeName());
        aResult->AssignCat ("& ");
        aResult->AssignCat (aParam->Name());
      }
      else
      {
        aResult->AssignCat (aParam->TypeName());
        if (aParam->IsOut())
        {
          aResult->AssignCat ("& ");
        }
        else
        {
          aResult->AssignCat (" ");
        }
        aResult->AssignCat (aParam->Name());
      }
    }
    else
    {
      aResult->AssignCat (aParam->TypeName());
      aResult->AssignCat ("& ");
      aResult->AssignCat (aParam->Name());
    }

    if (aParam->GetValueType() != MS_NONE
     && withDefaultValue)
    {
      MS_ParamWithValue* pwv = (MS_ParamWithValue*)aParam.operator->();
      aResult->AssignCat (" = ");
      aResult->AssignCat (pwv->GetValue());
    }
  }
  return aResult;
}

// build a c++ declaration method
// the result is in the EDL variable VMethod
//
//   template used :
//
//         MethodTemplateDef
//         ConstructorTemplateDef
//         MethodTemplateDec
//         ConstructorTemplateDec
//         InlineMethodTemplateDec
//
//   the EDL variables : 
//        VMethodHeader : must contains the name of the template used for 
//                        methods construction
//        VConstructorHeader :  must contains the name of the template used for 
//                              constructors construction
//
//=======================================================================
//function : CPP_BuildMethod
//purpose  : 
//=======================================================================
void CPP_BuildMethod(const Handle(MS_MetaSchema)& aMeta, 
		     const Handle(EDL_API)& api, 
		     const Handle(MS_Method)& m,
		     const Handle(TCollection_HAsciiString)& methodName,
		     const Standard_Boolean forDeclaration = Standard_True)
{
  Handle(MS_InstMet)  im;
  Handle(MS_ClassMet) cm;
  Handle(MS_Construc) ct;
  Handle(MS_Param)    retType;

  Handle(TCollection_HAsciiString) MetTemplate,
                                   ConTemplate;

  Standard_Boolean InlineMethod;

  MetTemplate = api->GetVariableValue(VMethodHeader);
  ConTemplate = api->GetVariableValue(VConstructorHeader);

  // here we process all the common attributes of methods
  //
  api->AddVariable(VMethodComment, m->Comment()->ToCString());
  Handle(TCollection_HAsciiString) aMethodName = methodName;
  if (!m->Params().IsNull())
  {
    aMethodName = new TCollection_HAsciiString (aMethodName);
    aMethodName->AssignCat (" ");
  }
  api->AddVariable(VMethodName, aMethodName->ToCString());
  api->AddVariable(VVirtual,"");
  
  // it s inline method ?
  //
  if (m->IsInline()) {
    api->AddVariable(VIsInline,"yes");
    InlineMethod = Standard_True;
  }
  else {
    InlineMethod = Standard_False;
    api->AddVariable(VIsInline,"no");
  }
    
  // it s returning const ?
  //
  if (m->IsConstReturn()) {
    api->AddVariable(VRetSpec,"const ");
  }
  else {
    api->AddVariable(VRetSpec,"");
  }
  
  // it s returning & ?
  //
  Standard_CString pC[3]={"&","*",""};
  Standard_Integer iX;
  //
  iX=2;
  if (m->IsRefReturn()) {
    iX=0;
  }
  else if (m->IsPtrReturn()) {
    iX=1;
  }
  api->AddVariable(VAnd, pC[iX]);
  //
  //
  Handle(TCollection_HAsciiString) aParamList = CPP_BuildParameterList(aMeta,
								       m->Params(), 
								       forDeclaration);
  api->AddVariable(VArgument, aParamList->ToCString());
  //api->AddVariable(VArgument,
	//	   CPP_BuildParameterList(aMeta,
		//			  m->Params(), 
			//		  forDeclaration)->ToCString());
  
  // it s returning a type or void
  //
  retType = m->Returns();
  if (!retType.IsNull()) {
    char *pTypeRet, *pTypeName;
    //
    const Handle(TCollection_HAsciiString)& aTypeName=retType->TypeName();
    pTypeName=(char *)aTypeName->ToCString();
    //
    Handle(TCollection_HAsciiString) aTypeRet = CPP_BuildType(aMeta,aTypeName);
    pTypeRet=(char *)aTypeRet->ToCString();
    //pTypeRet=(char *)CPP_BuildType(aMeta,aTypeName)->ToCString();
    //
    //modified by NIZNHY-PKV Mon May  5 15:10:12 2008f
    if (m->IsPtrReturn()) {
      
      if (aMeta->IsDefined(aTypeName)) {
	const Handle(MS_Type)& aType= aMeta->GetType(aTypeName);
	if (aType->IsKind(STANDARD_TYPE(MS_Class))) {
	  const Handle(MS_Class)& aClass=*((Handle(MS_Class)*)&aType);
	  if (aClass->IsPersistent() || aClass->IsTransient()) {
	    pTypeRet=pTypeName;
	  }
	}
      }
    }
    //modified by NIZNHY-PKV Mon May  5 15:10:15 2008t
    //
    api->AddVariable(VReturn, pTypeRet);
  }
  else {
    api->AddVariable(VReturn,"void");
  }
  
  // now the specials attributes
  //
  // instance methods
  //
  if (m->IsKind(STANDARD_TYPE(MS_InstMet))) {
    im = *((Handle(MS_InstMet)*)&m);
    
    api->AddVariable(VIsCreateMethod,"no");

    TCollection_AsciiString aVMetSpec = "";
    Standard_Boolean isDerived = TCollection_AsciiString (api->GetVariable (VInherits).GetValue()).Length();

    if (!im->IsDeferred() || !forDeclaration)
    {
      if (!im->IsStatic() && forDeclaration)
      {
        api->AddVariable(VVirtual,"virtual ");
      }
    
      if (im->IsConst())
      {
        aVMetSpec += " const";
      }

      if (im->IsRedefined() && isDerived)
      {
        aVMetSpec += " Standard_OVERRIDE";
      }
    }
    else if (forDeclaration)
    {
      api->AddVariable(VVirtual,"virtual ");

      if (im->IsConst())
      {
        aVMetSpec += " const";
      }

      if (im->IsRedefined() && isDerived)
      {
        aVMetSpec += " Standard_OVERRIDE";
      }

      aVMetSpec += " = 0";
    }

    api->AddVariable(VMetSpec, aVMetSpec.ToCString());

    api->Apply(VMethod,MetTemplate->ToCString());
    
    if (InlineMethod) {
      api->Apply(VMethod,"InlineMethodTemplateDec");
    }
  }
  //
  // class methods
  //
  else if (m->IsKind(STANDARD_TYPE(MS_ClassMet))) {
    api->AddVariable(VIsCreateMethod,"no");
    api->AddVariable(VMetSpec,"");
    if (forDeclaration) {
      api->AddVariable(VVirtual,"static ");
    }
    api->Apply(VMethod,MetTemplate->ToCString());
    
    if (InlineMethod) {
      api->Apply(VMethod,"InlineMethodTemplateDec");
    }
  }
  //
  // constructors
  //
  else if (m->IsKind(STANDARD_TYPE(MS_Construc))) {
    api->AddVariable(VIsCreateMethod,"yes");
    api->Apply(VMethod,ConTemplate->ToCString());

    if (InlineMethod) {
      api->Apply(VMethod,"InlineMethodTemplateDec");
    }
  }
  //
  // package methods
  //
  else if (m->IsKind(STANDARD_TYPE(MS_ExternMet))) {
    api->AddVariable(VIsCreateMethod,"no");
    api->AddVariable(VMetSpec,"");
    if (forDeclaration) {
      api->AddVariable(VVirtual,"static ");
    }

    api->Apply(VMethod,MetTemplate->ToCString());
    if (InlineMethod) {
      api->Apply(VMethod,"InlineMethodTemplateDec");
    }
  }  
}

// build an INLINE "function call" body method for "C++: function call" comment
//
Handle(TCollection_HAsciiString) CPP_BuildFunctionCall(const Handle(MS_MetaSchema)& aMeta,
//						       const Handle(EDL_API)& api,
						       const Handle(EDL_API)& ,
						       const Handle(MS_MemberMet)& method,
						       const Standard_Boolean isInlineMode)
{
  Handle(TCollection_HAsciiString) result = new TCollection_HAsciiString;
  Handle(MS_Param)                 retType;
  Standard_Integer                 i;
  Handle(MS_Type)                  type;
  Standard_CString                 calltype = NULL;

  type = aMeta->GetType(method->Class());

  if (type->IsKind(STANDARD_TYPE(MS_StdClass))) {
    Handle(MS_StdClass) stdclass = *((Handle(MS_StdClass)*)&type);

    if (stdclass->IsTransient() || stdclass->IsPersistent()) {
      calltype = "->";
    }
    else {
      calltype = ".";
    }
  }

  // for inline function mode
  //
  if (isInlineMode) {
    result->AssignCat("inline ");
  }

  // it s returning a type or void
  //
  retType = method->Returns();
  
  if (!retType.IsNull()) {
    if (method->IsConstReturn()) {
      result->AssignCat("const ");
    }

    result->AssignCat(CPP_BuildType(aMeta,retType->TypeName()));

    if (method->IsRefReturn()) {
      result->AssignCat("& ");
    }
  }
  else {
    result->AssignCat( "void");
  }

  result->AssignCat(" ");
  result->AssignCat(method->Name());
  result->AssignCat("(");

  if (method->IsKind(STANDARD_TYPE(MS_InstMet))) {
    Handle(MS_InstMet) im = *((Handle(MS_InstMet)*)&method);
    
    // if immutable
    //
    if (im->IsConst()) { 
      result->AssignCat("const ");
    }
  }

  result->AssignCat(CPP_BuildType(aMeta,method->Class()));
  result->AssignCat("& me");
  
  if (!method->Params().IsNull()) {
    result->AssignCat(",");
    result->AssignCat(CPP_BuildParameterList(aMeta,method->Params(),Standard_True));
  }

  
  result->AssignCat(") {\n");
  
  if (!retType.IsNull()) {
    result->AssignCat(" return");
  }

  result->AssignCat(" me");
  result->AssignCat(calltype);
  result->AssignCat(method->Name());
  result->AssignCat("(");

  if (!method->Params().IsNull()) {
    result->AssignCat(method->Params()->Value(1)->Name());
    for (i = 2; i <= method->Params()->Length(); i++) {
      result->AssignCat(",");
      result->AssignCat(method->Params()->Value(i)->Name());
    }
  }
  result->AssignCat(");\n");
  
  result->AssignCat("}\n\n");

  return result;
}

// build a method from a "---C++: alias" comment
//
Handle(TCollection_HAsciiString) CPP_BuildAliasMethod(const Handle(MS_MetaSchema)& aMeta,
						      const Handle(EDL_API)& api,
						      const Handle(MS_MemberMet)& method)
{
  Handle(TCollection_HAsciiString) result;

  if (!method->IsDestructor() && !method->IsFunctionCall()) {
    result = new TCollection_HAsciiString(method->IsAlias());
  }
  else {
    result = new TCollection_HAsciiString("~");
    result->AssignCat(method->Class());
    result->AssignCat("()");
  }
  // alias is kind : "void *new(size_t);"
  //  we only need to kill the quotes
  //
  if (method->IsQuotedAlias() && !method->IsDestructor()) {
    result->Remove(1);
    if (result->Value(result->Length()) == '"') {
      result->Remove(result->Length());
    }
    result->AssignCat("\n");
  }
  // C++: function call
  //
  else if (method->IsFunctionCall()) {
    result = CPP_BuildFunctionCall(aMeta,api,method,Standard_True); // <-- Standard_True = inline mode
  } 
  else {
    Handle(TCollection_HAsciiString) body = new TCollection_HAsciiString;
    Handle(MS_HArray1OfParam)      aSeq = method->Params();
    Standard_Integer                 i;

    if (!method->IsDestructor()) {
      CPP_BuildMethod(aMeta,api,method,result,Standard_False);
    }
    else {
      api->AddVariable(VMethod,result->ToCString());
    }

    result = api->GetVariableValue(VMethod);

    if (!method->Returns().IsNull()) {
      body->AssignCat("return ");
    }

    body->AssignCat(method->Name());
    body->AssignCat("(");

    if(!aSeq.IsNull()) {
      for (i = 1; i < aSeq->Length(); i++) {
	body->AssignCat(aSeq->Value(i)->Name());
	body->AssignCat(",");
      }

      body->AssignCat(aSeq->Value(aSeq->Length())->Name());
    }
    body->AssignCat(");");
    
    api->AddVariable(VMBody,body->ToCString());
    api->Apply(VMethod,"MethodTemplateDef");

    result = api->GetVariableValue(VMethod);
  }

  return result;
}


// Build the list of friends methods and set the result at the end of
// publics
//
Standard_Boolean CPP_SetFriendMethod(const Handle(MS_MetaSchema)& aMeta,
				     const Handle(EDL_API)& api,
				     const Handle(TColStd_HSequenceOfHAsciiString)& FriendMets,
				     const Handle(TCollection_HAsciiString)& publics)
{
  if (publics.IsNull()) return Standard_False;

  Handle(MS_Method)                friendmethod;
  Standard_Integer                 i;
  Standard_Boolean                 result = Standard_True;
  Handle(TCollection_HAsciiString) aname,
                                   oldclass = api->GetVariableValue(VClass);

  // templates for methods extraction
  //
  api->AddVariable(VMethodHeader,"ExternalMethodHeader");
  api->AddVariable(VConstructorHeader,"ExternalConstructorHeader");
  
  for (i = 1; i <= FriendMets->Length(); i++) {
    friendmethod.Nullify();
    friendmethod = MS::GetMethodFromFriendName(aMeta,FriendMets->Value(i));
    
    if (!friendmethod.IsNull()) {
      aname = FriendMets->Value(i)->Token(":");
      api->AddVariable(VClass,aname->ToCString());
      publics->AssignCat("friend ");
      CPP_BuildMethod(aMeta,api,friendmethod,friendmethod->Name(),Standard_False);
      api->Apply(VMethod,"MethodTemplateDec");
      publics->AssignCat(api->GetVariableValue(VMethod));
    }
    else {
      result = Standard_False;
    }
  }
  
  // templates for methods extraction
  //
  api->AddVariable(VMethodHeader,"MethodHeader");
  api->AddVariable(VConstructorHeader,"ConstructorHeader");
  api->AddVariable(VClass,oldclass->ToCString());

  return result;
}

// create the defines and the undefines that are around the include of
// a generic .lxx
//  ex. :
//    #define ItemHArray1 Quantity_Color
//    #define ItemHArray1_hxx <Quantity_Color.hxx>
//    #define TheArray1 Quantity_Array1OfColor
//    #define TheArray1_hxx <Quantity_Array1OfColor.hxx>
//    #define TCollection_HArray1 Quantity_HArray1OfColor
//    #define TCollection_HArray1_hxx <Quantity_HArray1OfColor.hxx>
//    #include <TCollection_HArray1.lxx>
//    #undef ItemHArray1
//    #undef ItemHArray1_hxx
//    #undef TheArray1
//    #undef TheArray1_hxx
//    #undef TCollection_HArray1
//    #undef TCollection_HArray1_hxx
//
void CPP_GenericDefine(const Handle(MS_MetaSchema)& aMeta,
		       const Handle(EDL_API)& api,
		       const Handle(MS_InstClass)& aCreator,
		       const Standard_CString VARDefine,
		       const Standard_CString VARUndefine,
//		       const Standard_Boolean handleUsed)
		       const Standard_Boolean )
{
  Handle(MS_GenClass)                     aGenClass   = Handle(MS_GenClass)::DownCast(aMeta->GetType(aCreator->GenClass()));
  Handle(TColStd_HSequenceOfHAsciiString) theGenTypes = aCreator->GenTypes();
  Handle(TCollection_HAsciiString)        publics     = new TCollection_HAsciiString;
  Handle(TCollection_HAsciiString)        protecteds  = new TCollection_HAsciiString;
  Standard_Integer                        i,
                                          itemLength;
  Handle(MS_HSequenceOfGenType)           realGentypes = aGenClass->GenTypes();

  // we need this length because for item we must call 
  // CPP_BuildType and for nested class name we dont need. 
  //
  itemLength = aGenClass->GenTypes()->Length();

  for (i = 1; i <= theGenTypes->Length(); i++) {
    if (!aGenClass->FullName()->IsSameString(theGenTypes->Value(i))) {
      api->AddVariable(VDName,theGenTypes->Value(i)->ToCString());

      // real name or Handle_name
      //
      if (i <= itemLength) { 
	if (!realGentypes->Value(i)->TYpeName().IsNull()) {
	  if (aMeta->IsDefined(realGentypes->Value(i)->TYpeName())) {
	    Handle(MS_Type) t = aMeta->GetType(realGentypes->Value(i)->TYpeName());

	    if (t->IsKind(STANDARD_TYPE(MS_Class))) {
	      Handle(MS_Class) c = *((Handle(MS_Class)*)&t);
	      
	      // if the items constraint is handled, the item is not the handle,
	      // like in other cases, but the type himself.
	      //
	      // ex. : the item : 'i' as transient
	      //    will be defined as #define i class
	      //       the item : 'i' as any
	      //    will be defined as #define i Handle_Class
	      //
	      if (c->IsPersistent() || c->IsTransient()) {
		api->AddVariable(VDValue,aCreator->InstTypes()->Value(i)->ToCString());
		api->Apply(VARDefine,"ItemConstraintHandle");
		api->Apply(VARUndefine,"ItemConstraintHandleUndef");
		publics->AssignCat(api->GetVariableValue(VARDefine));
		protecteds->AssignCat(api->GetVariableValue(VARUndefine));
	      }
	      else {
		api->AddVariable(VDValue,CPP_BuildType(aMeta,aCreator->InstTypes()->Value(i))->ToCString());
	      }
	    }
	  }
	}
	else {
	  api->AddVariable(VDValue,CPP_BuildType(aMeta,aCreator->InstTypes()->Value(i))->ToCString());
	}
	api->AddVariable("%DBaseValue",aCreator->InstTypes()->Value(i)->ToCString());
      }
      // real name
      //
      else { 
	api->AddVariable(VDValue,aCreator->InstTypes()->Value(i)->ToCString());
	api->AddVariable("%DBaseValue",aCreator->InstTypes()->Value(i)->ToCString());
      }

      api->Apply(VARDefine,"ItemDefine");
      api->Apply(VARUndefine,"ItemUndefine");
      publics->AssignCat(api->GetVariableValue(VARDefine));
      protecteds->AssignCat(api->GetVariableValue(VARUndefine));
    }
  }
  
  for (i = itemLength + 1; i <= theGenTypes->Length(); i++) {
    if (!aGenClass->FullName()->IsSameString(theGenTypes->Value(i))) {
      Handle(TCollection_HAsciiString) realName = CPP_BuildType(aMeta,aCreator->InstTypes()->Value(i));
      
      if (!realName->IsSameString(aCreator->InstTypes()->Value(i))) {
	api->AddVariable(VDName,theGenTypes->Value(i)->ToCString());
	api->AddVariable(VDValue,aCreator->InstTypes()->Value(i)->ToCString());
	api->Apply(VARDefine,"ItemHandleDefine");
	api->Apply(VARUndefine,"ItemHandleUndefine");
	publics->AssignCat(api->GetVariableValue(VARDefine));
	protecteds->AssignCat(api->GetVariableValue(VARUndefine));
      }
    }
  }

  api->AddVariable(VDName,aGenClass->FullName()->ToCString());
  api->AddVariable(VDValue,aCreator->FullName()->ToCString());
  api->AddVariable("%DBaseValue",aCreator->FullName()->ToCString());

  api->Apply(VARDefine,"ItemDefine");
  api->Apply(VARUndefine,"ItemUndefine");
  publics->AssignCat(api->GetVariableValue(VARDefine));
  protecteds->AssignCat(api->GetVariableValue(VARUndefine));

  // #define TCollection_HSequence_Type_() TColStd_HSequenceOfTransient_Type_()
  // #define Handle_TCollection_HSequence Handle_TColStd_HSequenceOfTransient
  //
  if (aGenClass->IsTransient() || aGenClass->IsPersistent()) {
    api->AddVariable(VDName,aGenClass->FullName()->ToCString());
    api->AddVariable(VDValue,aCreator->FullName()->ToCString());
    api->Apply(VARDefine,"ItemHandleDefine");
    api->Apply(VARUndefine,"ItemHandleUndefine");
    publics->AssignCat(api->GetVariableValue(VARDefine));
    protecteds->AssignCat(api->GetVariableValue(VARUndefine));
  }

  api->AddVariable(VARDefine,publics->ToCString());
  api->AddVariable(VARUndefine,protecteds->ToCString());
}



//void CPP_ClassTypeMgt(const Handle(MS_MetaSchema)& aMeta,
void CPP_ClassTypeMgt(const Handle(MS_MetaSchema)& ,
		      const Handle(EDL_API)& api,
		      const Handle(MS_Class)& aClass,
		      const Standard_CString var)
{
  Handle(TColStd_HSequenceOfHAsciiString) inh = aClass->GetFullInheritsNames();
  Standard_Integer                        i;
  Handle(TCollection_HAsciiString)        ichar;
  Handle(TCollection_HAsciiString)        str  = new TCollection_HAsciiString;
  Handle(TCollection_HAsciiString)        str1 = new TCollection_HAsciiString;

  for (i = 1; i <= inh->Length(); i++) {
    ichar = new TCollection_HAsciiString(i);

    api->AddVariable(VNb,ichar->ToCString());
    api->Apply(VNb,"TypeMgtAncestorType");

    str1->AssignCat(api->GetVariableValue(VNb));
    str1->AssignCat(",");
    
    api->AddVariable(VAncestors,inh->Value(i)->ToCString());
    api->Apply(VInherits,"TypeMgtAncestor");
    str->AssignCat(api->GetVariableValue(VInherits));
  }

  api->AddVariable(VInherits,str->ToCString());
  api->AddVariable(VAncestors,str1->ToCString());
  api->AddVariable(VClass,aClass->FullName()->ToCString());
  //api->AddVariable(VClassComment,aClass->Comment()->ToCString());

  api->Apply(var,"TypeMgt");
}


// Standard extractor API : launch the extraction of C++ files
//                          from the type <aName>
// 
void CPP_Extract(const Handle(MS_MetaSchema)& aMeta,
		 const Handle(TCollection_HAsciiString)& aName,
		 const Handle(TColStd_HSequenceOfHAsciiString)& edlsfullpath,
		 const Handle(TCollection_HAsciiString)& outdir,
		 const Handle(TColStd_HSequenceOfHAsciiString)& outfile,
		 const Standard_CString DBMS)
{
  Handle(MS_Type)     srcType;
  Handle(MS_Package)  srcPackage;
  

  // before begining, we look if the entity has something to extract...
  //
  if (aMeta->IsDefined(aName)) {
    srcType   = aMeta->GetType(aName); 
  }
  else if (aMeta->IsPackage(aName)) {
    srcPackage = aMeta->GetPackage(aName);
  }
  else {
    ErrorMsg() << "CPPExt" << aName->ToCString() << " not defined..." << endm;
    Standard_NoSuchObject::Raise();
  }
  
  // ... and we load the templates
  //
  Handle(EDL_API)     api;

  // Package Extraction
  //
  if (!srcPackage.IsNull()) {
    if (srcPackage->Methods()->Length() > 0) {
      api = CPP_LoadTemplate(edlsfullpath,outdir,DBMS);
      CPP_Package(aMeta,api,srcPackage,outfile);
    }
    else {
      return;
    }
  }
  // Extraction of Classes
  //
  else if (srcType->IsKind(STANDARD_TYPE(MS_StdClass)) && !srcType->IsKind(STANDARD_TYPE(MS_GenClass)) && !srcType->IsKind(STANDARD_TYPE(MS_InstClass))) {
    Handle(MS_StdClass) aClass = *((Handle(MS_StdClass)*)&srcType);
    
    if (aClass->Incomplete()) {
      ErrorMsg() << "CPPExt" << aName->ToCString() << " not complete..." << endm;
      Standard_NoSuchObject::Raise();
    }

    if (aClass->IsGeneric()
     || aClass->Imported())
    {
      return;
    }

    api = CPP_LoadTemplate(edlsfullpath,outdir,DBMS);

    // Transient classes
    //
    if (aClass->IsTransient()
    && !aName->IsSameString (MS::GetTransientRootName()))
    {
      if (aClass->GetInheritsNames()->Length() == 0)
      {
        ErrorMsg() << "CPPExt" << "incomplete metaschema..." << endm;
        Standard_NoSuchObject::Raise();
      }

      Handle(TCollection_HAsciiString) aHandleFile = new TCollection_HAsciiString(outdir);
      aHandleFile->AssignCat("Handle_");
      aHandleFile->AssignCat(aName);
      aHandleFile->AssignCat(".hxx");

      outfile->Append(aHandleFile);
      CPP_TransientHandle(api,aName,aClass->GetInheritsNames()->Value(1),aHandleFile);

      if (aClass->IsKind(STANDARD_TYPE(MS_Error)))
      {
        CPP_ExceptionClass(aMeta,api,aClass,outfile);
      }
      else
      {
        CPP_TransientClass(aMeta,api,aClass,outfile);
      }
    }
    // Persistent classes
    //
    else if (aClass->IsPersistent()
         && !aName->IsSameString(MS::GetPersistentRootName()))
    {
      if (aClass->GetInheritsNames()->Length() == 0)
      {
        ErrorMsg() << "CPPExt" << "incomplete metaschema..." << endm;
        Standard_NoSuchObject::Raise();
      }

      Handle(TCollection_HAsciiString) aHandleFile = new TCollection_HAsciiString(outdir);
      
      aHandleFile->AssignCat("Handle_");
      aHandleFile->AssignCat(aName);
      aHandleFile->AssignCat(".hxx");

      outfile->Append(aHandleFile);

      if (!strcmp(api->GetVariableValue("%CPPEXTDBMS")->ToCString(),"OBJY"))
      {
        CPP_PersistentHandleOBJY(api,aName,aClass->GetInheritsNames()->Value(1),aHandleFile);
        CPP_PersistentClassOBJY(aMeta,api,aClass,outfile);
      }
      else if (!strcmp(api->GetVariableValue("%CPPEXTDBMS")->ToCString(),"MEM"))
      {
      }
      else if (!strcmp(api->GetVariableValue("%CPPEXTDBMS")->ToCString(),"OBJS"))
      {
        CPP_PersistentHandleOBJS(api,aName,aClass->GetInheritsNames()->Value(1),aHandleFile);
        CPP_PersistentClassOBJS(aMeta,api,aClass,outfile);
      }
      else if (!strcmp(api->GetVariableValue("%CPPEXTDBMS")->ToCString(),"OO2"))
      {
      }
      else if (!strcmp(api->GetVariableValue("%CPPEXTDBMS")->ToCString(),"CSFDB"))
      {
        CPP_PersistentHandleCSFDB(api,aName,aClass->GetInheritsNames()->Value(1),aHandleFile);
        CPP_PersistentClassCSFDB(aMeta,api,aClass,outfile);
      }
    }
    // Storable classes
    //
    else if (aClass->IsStorable())
    {
      CPP_StorableClass(aMeta,api,aClass,outfile);
    } 
    // MPV classes
    //
    else
    {
      CPP_MPVClass(aMeta,api,aClass,outfile);
    }
  }
  // Enumerations
  //
  else if (srcType->IsKind(STANDARD_TYPE(MS_Enum)))
  {
    Handle(MS_Enum) anEnum = *((Handle(MS_Enum)*)&srcType);
  
    api = CPP_LoadTemplate(edlsfullpath,outdir,DBMS);
    CPP_Enum(aMeta,api,anEnum,outfile);
  }
  // Aliases
  //
  else if (srcType->IsKind(STANDARD_TYPE(MS_Alias)))
  {
    Handle(MS_Alias) anAlias = *((Handle(MS_Alias)*)&srcType);

    api = CPP_LoadTemplate(edlsfullpath,outdir,DBMS);
    CPP_Alias(aMeta,api,anAlias,outfile);
  }
  else if (srcType->IsKind(STANDARD_TYPE(MS_Pointer)))
  {
    Handle(MS_Pointer) aPointer = *((Handle(MS_Pointer)*)&srcType);

    api = CPP_LoadTemplate(edlsfullpath,outdir,DBMS);
    CPP_Pointer(aMeta,api,aPointer,outfile);
  }
}
		 
Handle(TCollection_HAsciiString) CPP_WithoutHandleSuffix (const Handle(TCollection_HAsciiString)& theName)
{
  const Standard_Integer aSuffLen = Standard_Integer(sizeof("Handle_") - 1);
  if (theName->Length() > aSuffLen
   && theName->SubString (1, aSuffLen)->String() == "Handle_")
  {
    return theName->SubString (aSuffLen + 1, theName->Length());
  }
  return theName;
}
