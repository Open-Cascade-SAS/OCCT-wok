#include <MS_Method.ixx>
#include <MS_MetaSchema.hxx>
#include <MS_InstMet.hxx>

#define MET_DESTROY  0x01
#define MET_PRIVATE  0x02
#define MET_CONST    0x04
#define MET_REF      0x08
#define MET_INLINE   0x10
#define MET_OPERATOR 0x20
#define MET_FUNCCALL 0x40

MS_Method::MS_Method(const Handle(TCollection_HAsciiString)& aName) : MS_Common(aName),myAttribute(0),myRaises(new TColStd_HSequenceOfHAsciiString)
{
}

void MS_Method::CreateFullName() 
{
  Standard_Integer                 i;
  Handle(TCollection_HAsciiString) myIdName;

  myIdName = new TCollection_HAsciiString;
  myIdName->AssignCat(Name());
  myIdName->AssignCat("(");

  if (!myParam.IsNull()) {
    if (myParam->Value(1)->IsLike()) {
      myIdName->AssignCat("LikeMe");
    }
    else {
      myIdName->AssignCat(myParam->Value(1)->TypeName());
    }
  }

  if(!myParam.IsNull()) {
    for(i = 2; i <= myParam->Length(); i++) {
      myIdName->AssignCat(",");
      if (myParam->Value(i)->IsLike()) {
	myIdName->AssignCat("LikeMe");
      }
      else {
	myIdName->AssignCat(myParam->Value(i)->TypeName());
      }
    }
  }

  myIdName->AssignCat(")");

  if (!myReturns.IsNull()) {
    myIdName->AssignCat("=");

    if (myReturns->IsLike()) {
      myIdName->AssignCat("LikeMe");
    }
    else {
      myIdName->AssignCat(myReturns->TypeName());
    }
  }

  FullName(myIdName);
}

void MS_Method::Params(const Handle(MS_HSequenceOfParam)& params)
{
  if(!params.IsNull()) {
    myParam = new MS_HArray1OfParam(1, params->Length());
    for(Standard_Integer i=1; i<=params->Length(); i++)
      myParam->ChangeValue(i) = params->Value(i);
  }
  //myParam->Append(aParam);
}

Handle(MS_HArray1OfParam) MS_Method::Params() const 
{
  return myParam;
}

void MS_Method::Private(const Standard_Boolean aPrivate)
{
  if (aPrivate) {
    myAttribute |= MET_PRIVATE;
  }
  else {
    myAttribute &= (myAttribute ^ MET_PRIVATE);
  }
}

Standard_Boolean MS_Method::Private() const 
{
  if (myAttribute & MET_PRIVATE) {
    return Standard_True;
  }
  else {
    return Standard_False;
  }
}

void MS_Method::Returns(const Handle(MS_Param)& aParam)
{
  myReturns = aParam;
}

Handle(MS_Param) MS_Method::Returns() const 
{
  return myReturns;
}

void MS_Method::Raises(const Handle(TCollection_HAsciiString)& aRaise)
{
  if(myRaises.IsNull()) myRaises = new TColStd_HSequenceOfHAsciiString;
  myRaises->Append(aRaise);
}

Handle(TColStd_HSequenceOfHAsciiString) MS_Method::GetRaisesName() const 
{
  return myRaises;
}

void MS_Method::Inline(const Standard_Boolean anInline)
{
  if (anInline) {
    myAttribute |= MET_INLINE;
  }
  else {
    myAttribute &= (MET_INLINE ^ myAttribute);
  }    
}

Standard_Boolean MS_Method::IsInline() const 
{
  if (myAttribute & MET_INLINE) {
    return Standard_True;
  }
  else {
    return Standard_False;
  }
}

void MS_Method::ConstReturn(const Standard_Boolean aConst)
{
  if (aConst) {
    myAttribute |= MET_CONST;
  }
  else {
    myAttribute &= (MET_CONST ^ myAttribute);
  }   
}

Standard_Boolean MS_Method::IsConstReturn() const 
{
  if (myAttribute & MET_CONST) {
    return Standard_True;
  }
  else {
    return Standard_False;
  }
}

void MS_Method::Alias(const Handle(TCollection_HAsciiString)& anAlias)
{
  myAlias = anAlias;
}

Handle(TCollection_HAsciiString) MS_Method::IsAlias() const 
{
  return myAlias;
}

void MS_Method::RefReturn(const Standard_Boolean aRef)
{
  if (aRef) {
    myAttribute |= MET_REF;
  }
  else {
    myAttribute &= (MET_REF ^ myAttribute);
  }   
}

Standard_Boolean MS_Method::IsRefReturn() const 
{
  if (myAttribute & MET_REF) {
    return Standard_True;
  }
  else {
    return Standard_False;
  }
}

void MS_Method::Destructor(const Standard_Boolean aDestructor)
{
  if (aDestructor) {
    myAttribute |= MET_DESTROY;
  }
  else {
    myAttribute &= (MET_DESTROY ^ myAttribute);
  }   
}

Standard_Boolean MS_Method::IsDestructor() const 
{
 if (myAttribute & MET_DESTROY) {
    return Standard_True;
  }
  else {
    return Standard_False;
  } 
}

void MS_Method::FunctionCall(const Standard_Boolean aFunctionCall)
{
  if (aFunctionCall) {
    myAttribute |= MET_FUNCCALL;
  }
  else {
    myAttribute &= (MET_FUNCCALL ^ myAttribute);
  }   
}

Standard_Boolean MS_Method::IsFunctionCall() const 
{
  if (myAttribute & MET_FUNCCALL) {
    return Standard_True;
  }
  else {
    return Standard_False;
  } 
}

Standard_Boolean MS_Method::IsSameSignature(const Handle(TCollection_HAsciiString)& aMetName2) const
{
  Handle(TCollection_HAsciiString) aMetName1;
  Standard_Boolean result = Standard_False;

  
  if (!aMetName2.IsNull() ) {
    aMetName1 = FullName();

    Standard_CString aname1 = strchr(aMetName1->ToCString(), ':');
    Standard_CString aname2 = strchr(aMetName2->ToCString(), ':');

    Standard_CString fin1 = strchr(aname1, '=');
    Standard_CString fin2 = strchr(aname2, '=');

    if(fin1) *fin1 = '\0';
    if(fin2) *fin2 = '\0';

    //cout << "aname1 : " << aname1 << endl;
    //cout << "aname2 : " << aname2 << endl;

    result = !strcmp(aname1, aname2);

    //cout << "result : " << result << endl;

    if(fin1) *fin1 = '=';
    if(fin2) *fin2 = '=';

//     Handle(TCollection_HAsciiString) aname1 = aMetName1->Token(":",2),
//                                      aname2 = aMetName2->Token(":",2);
  
//     aname1 = aname1->Token("=");
//     aname2 = aname2->Token("=");
//     result = aname1->IsSameString(aname2);

    if (result) {
      Handle(MS_Method)           m1,m2;
      Handle(MS_HArray1OfParam) p1,p2;

      m1 = this;
      m2 = GetMetaSchema()->GetMethod(aMetName2);

      if (m1->IsKind(STANDARD_TYPE(MS_InstMet)) && m2->IsKind(STANDARD_TYPE(MS_InstMet))) {
        Handle(MS_InstMet)           im1,im2;

        result = Standard_False;
        im1 = *((Handle_MS_InstMet*)&m1);
        im2 = *((Handle_MS_InstMet*)&m2);

        if (im1->IsConst() == im2->IsConst()) {
           result = Standard_True;
        }
      }

      // DEBUG PRO7950   N3       Fun.=UNK  Res.=CLE 
      //       Pas de check de la signature "in out mutable" dans une methode redefinie 
      //
      if (result) {
        p1 = m1->Params();
        p2 = m2->Params();

	if (!p1.IsNull()) {
	  result = Standard_False;
	  Standard_Integer i;
	  Handle(MS_Param) pa1,pa2;
	  
	  for (i = 1; i <= p1->Length(); i++) {
	    pa1 = p1->Value(i);
	    pa2 = p2->Value(i);
	    
	    if (pa1->IsOut() == pa2->IsOut()) {
	      if (pa1->IsIn() == pa2->IsIn()) {
		if (pa1->IsAny() == pa2->IsAny()) {
		  if (pa1->IsMutable() == pa2->IsMutable()) {
		    result = Standard_True;
		  }
		}
	      }
	    }
	  } 
	}
      }
      else result = Standard_True; // if (!p1.IsNull()) {
    }
  }

  return result;
}

void MS_Method::SetAliasType(const Standard_Boolean aType)
{
  if (aType) {
    myAttribute |= MET_OPERATOR;
  }
  else {
    myAttribute &= (MET_OPERATOR ^ myAttribute);
  }  
}

Standard_Boolean MS_Method::IsOperator() const 
{
  if (myAttribute & MET_OPERATOR) {
    return Standard_True;
  }
  else {
    return Standard_False;
  } 
}

Standard_Boolean MS_Method::IsQuotedAlias() const 
{
  return (!myAlias.IsNull() && !IsOperator());
}


