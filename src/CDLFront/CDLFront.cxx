// CDLFront.cxx      Version 1.1
//        Date: 06/04/1995

#include <CDLFront.hxx>

#include <MS.hxx>
#include <MS_AccessMode.hxx>
#include <MS_Alias.hxx>
#include <MS_Common.hxx>
#include <MS_Component.hxx>
#include <MS_Construc.hxx>
#include <MS_Class.hxx>
#include <MS_ClassMet.hxx>
#include <MS_Client.hxx>
#include <MS_Engine.hxx>
#include <MS_Enum.hxx>
#include <MS_Executable.hxx>
#include <MS_ExecFile.hxx>
#include <MS_ExecPart.hxx>
#include <MS_ExternMet.hxx>
#include <MS_Error.hxx>
#include <MS_Field.hxx>
#include <MS_GenClass.hxx>
#include <MS_GenType.hxx>
#include <MS_InstClass.hxx>
#include <MS_InstMet.hxx>
#include <MS_Interface.hxx>
#include <MS_Imported.hxx>
#include <MS_Language.hxx>
#include <MS_MetaSchema.hxx>
#include <MS_Method.hxx>
#include <MS_Package.hxx>
#include <MS_Param.hxx>
#include <MS_ParamWithValue.hxx>
#include <MS_Pointer.hxx>
#include <MS_PrimType.hxx>
#include <MS_Schema.hxx>
#include <MS_StdClass.hxx>
#include <MS_TraductionError.hxx>
#include <MS_HSequenceOfPackage.hxx>
#include <MS_HSequenceOfInterface.hxx>
#include <MS_HSequenceOfType.hxx>
#include <MS_HSequenceOfGenClass.hxx>
#include <MS_HSequenceOfMethod.hxx>
#include <MS_HSequenceOfExecPart.hxx>
#include <MS_HSequenceOfGenType.hxx>
#include <MS_HSequenceOfParam.hxx>
#include <OSD_Environment.hxx>
#include <Standard_ErrorHandler.hxx>
#include <TCollection_HAsciiString.hxx>
#include <TColStd_HSequenceOfHAsciiString.hxx>
#include <TColStd_HSequenceOfInteger.hxx>

#include <WOKTools_Messages.hxx>
#include <WOKTools_MapOfHAsciiString.hxx>

// lex and yacc glue includes
extern "C"
{
  #include <cdl_rules.h>
}
#include <cdl_defines.hxx>
#include <CDL.tab.h>

#include <cstring>
#include <cstdio>

#define THE_MAX_CHAR 256

// type of the current entity
enum
{
  CDL_NULL       = 0,
  CDL_PACKAGE    = 1,
  CDL_STDCLASS   = 2,
  CDL_GENCLASS   = 3,
  CDL_NESCLASS   = 4,
  CDL_INCDECL    = 5,
  CDL_GENTYPE    = 6,
  CDL_INTERFACE  = 7,
  CDL_EXECUTABLE = 8,
  CDL_CLIENT     = 9
};

enum
{
  CDL_CPP        = 1,
  CDL_FOR        = 2,
  CDL_C          = 3,
  CDL_OBJ        = 4,
  CDL_LIBRARY    = 5,
  CDL_EXTERNAL   = 6
};

enum
{
  CDL_MUSTNOTCHECKUSES = 0,
  CDL_MUSTCHECKUSES    = 1
};

// lex variable
//      line number
#ifndef _WIN32
  extern     int   CDLlineno;
  extern     FILE* CDLin;
#else
  extern "C" int   CDLlineno;
  extern "C" FILE* CDLin;
#endif

namespace
{
  static const Standard_Boolean THE_TO_WARN_LOST_DOCS = !OSD_Environment ("CSF_LOSTDOCS").Value().IsEmpty();

  static int   YY_nb_error;
  static int   YY_nb_warning;
  static Handle(TCollection_HAsciiString) TheCDLFileName;

  // line number of method definition (for C++ directive error)
  static Standard_Integer TheMethodLineNo = 0;

  // because we don't check uses for friends
  static Standard_Integer TheCheckUsesForClasses = CDL_MUSTCHECKUSES;
  static Standard_Integer TheCurrentEntity       = CDL_NULL;
  static Standard_Integer TheSaveState           = CDL_NULL;

  // The Flags
  static Standard_Boolean TheIsPrivate        = Standard_False,
                          TheIsProtected      = Standard_False,
                          TheIsStatic         = Standard_True,
                          TheIsDeferred       = Standard_False,
                          TheIsImported       = Standard_False,
                          TheIsTransient      = Standard_False,
                          TheIsRedefined      = Standard_False,
                          TheIsLike           = Standard_False,
                          TheIsAny            = Standard_False,
                          TheIsCPPReturnRef   = Standard_False,
                          TheIsCPPReturnConst = Standard_False,
                          TheIsCPPOperator    = Standard_False,
                          TheIsCPPAlias       = Standard_False,
                          TheIsCPPInline      = Standard_False;

  // The Identifiers
  static char TheTypeName[THE_MAX_CHAR + 1], //!< The name of the current type
              ThePackName[THE_MAX_CHAR + 1]; //!< The Name of package

  // The Classes
  static Standard_Integer TheMutable = 0,
                          TheInOrOut = MS_IN;

  // Container : an entity where type are declared or defined
  //   ex.: a package, an interface,...
  static Handle(TCollection_HAsciiString) TheContainer = new TCollection_HAsciiString();

  // The variables representing the analyze of current object
  // The Conventions:
  //   Beginning of analysis: a new object is creating
  //         End of analysis: the variable is nullified
  //
  static Handle(MS_Schema)                TheSchema;       //!< The current Schema
  static Handle(MS_Engine)                TheEngine;       //!< The current Engine
  static Handle(MS_Component)             TheComponent;    //!< The current Component

  static Handle(MS_Executable)            TheExecutable;   //!< The current Executable
  static Handle(MS_ExecPart)              TheExecPart;     //!< The current ExePart
  static Handle(MS_HSequenceOfExecPart)   TheExecTable;

  static int                              TheExecutableLanguage = CDL_CPP;
  static int                              TheExecutableUseType  = 0;

  static Handle(MS_Client)                TheClient;       //!< The current Client
  static Handle(MS_Interface)             TheInterface;    //!< The current Interface
  static Handle(MS_Package)               ThePackage;      //!< The current package
  static Handle(MS_Alias)                 TheAlias;        //!< The current Alias
  static Handle(MS_Pointer)               ThePointer;      //!< The current Pointer
  static Handle(MS_Imported)              TheImported;     //!< The current Imported
  static Handle(MS_PrimType)              ThePrimitive;    //!< The current Primitive
  static Handle(MS_Enum)                  TheEnum;         //!< The current enum
  static Handle(MS_Error)                 TheException;    //!< The Error (exception) class
  //! For dynamic generic instantiation like
  //! generic class toto (item1, this one --> item2 as list from TCollection(item1))
  static Handle(MS_GenType)               TheDynType;
  static Handle(MS_Class)                 TheSimpleClass;
  static Handle(MS_StdClass)              TheClass;        //!< The current class
  static Handle(MS_StdClass)              TheStdClass;     //!< The current class is a Standard Class
  static Handle(MS_StdClass)              TheGenStdClass;  //!< The current class descipt a Generic Class
  static Handle(MS_Error)                 TheError;        //!< The current class is a Exception
  static Handle(MS_GenClass)              TheGenClass;     //!< The current class is a Generic class
  static Handle(MS_InstClass)             TheInstClass;    //!< The current class is a instantiated class
  static Handle(MS_GenClass)              TheEmbeded;      //!< The current class is embedded class
  static Handle(TCollection_HAsciiString) TheMethodName = new TCollection_HAsciiString();
  static Handle(MS_Method)                TheMethod;       //!< The current method
  static Handle(MS_MemberMet)             TheMemberMet;    //!< The Member method
  static Handle(MS_ExternMet)             TheExternMet;    //!< The current method is a method of package
  static Handle(MS_Construc)              TheConstruc;     //!< The current method is a constructor
  static Handle(MS_InstMet)               TheInstMet;      //!< The current method is a method of instance
  static Handle(MS_ClassMet)              TheClassMet;     //!< The current method is a method of class
  static Handle(MS_HSequenceOfParam)      TheMethodParams; //!< The current method parameters
  static Handle(MS_MetaSchema)            TheMetaSchema;   //!< The most important : the meta-schema
  static Handle(MS_Field)                 TheField;        //!< The Field variables
  static Handle(TCollection_HAsciiString) TheDefCons = new TCollection_HAsciiString ("Initialize");
  static Handle(TCollection_HAsciiString) TheNorCons = new TCollection_HAsciiString ("Create");

  // The Parameter variables
  static Handle(MS_Param)                 TheParam;
  static Standard_Integer                 TheParamType = 0;
  static Handle(TCollection_HAsciiString) TheParamValue;
  // for clause like : type1,type2,type3, ... ,typen
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfTypes     = new TColStd_HSequenceOfHAsciiString();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfPackages  = new TColStd_HSequenceOfHAsciiString();

  // for generic classes (generic item1, ... ,generic itemn)
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfItem      = new TColStd_HSequenceOfHAsciiString();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfName      = new TColStd_HSequenceOfHAsciiString();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfCplusplus = new TColStd_HSequenceOfHAsciiString();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfComments  = new TColStd_HSequenceOfHAsciiString();
  static Standard_Boolean                        TheIsEmptyLineInComment = Standard_False;

  static Handle(TColStd_HSequenceOfInteger)      TheListOfCPPType   = new TColStd_HSequenceOfInteger();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfInteger   = new TColStd_HSequenceOfHAsciiString();
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfGlobalUsed;
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfTypeUsed;
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfInst;
  static Handle(TColStd_HSequenceOfHAsciiString) TheListOfGen;

  // this is a dummy package name for generic type (item, etc...)
  //
  static const char* THE_DUMMY_PACKAGE_NAME = "___D";
  static const char* THE_ROOT_PACKAGE       = "Standard";
  static char        ThePackNameFound[THE_MAX_CHAR + 1];

} // namespace

void CDL_MustNotCheckUses()
{
  TheCheckUsesForClasses = CDL_MUSTNOTCHECKUSES;
}

void CDL_MustCheckUses()
{
  TheCheckUsesForClasses = CDL_MUSTCHECKUSES;
}

void CDL_InitVariable()
{
  TheCheckUsesForClasses = CDL_MUSTCHECKUSES;
  TheCurrentEntity = CDL_NULL;
  TheSaveState      = CDL_NULL;
  TheIsPrivate        = Standard_False;
  TheIsProtected      = Standard_False;
  TheIsStatic         = Standard_True;
  TheIsDeferred       = Standard_False;
  TheIsImported       = Standard_False;
  TheIsTransient      = Standard_False;
  TheIsRedefined      = Standard_False;
  TheIsLike           = Standard_False;
  TheIsAny            = Standard_False;
  TheIsCPPReturnRef   = Standard_False;
  TheIsCPPReturnConst = Standard_False;
  TheIsCPPOperator    = Standard_False;
  TheIsCPPAlias       = Standard_False;
  TheIsCPPInline      = Standard_False;
  YY_nb_error   = 0;
  YY_nb_warning = 0;

  TheMutable = 0;
  TheInOrOut = MS_IN;
  TheContainer = new TCollection_HAsciiString;
  TheSchema.Nullify();
  TheEngine.Nullify();
  TheComponent.Nullify();
  TheExecutable.Nullify();
  TheExecPart.Nullify();
  TheExecTable.Nullify();
  TheExecutableLanguage = CDL_CPP;
  TheExecutableUseType = CDL_LIBRARY;
  TheInterface.Nullify();
  ThePackage.Nullify();
  TheAlias.Nullify();
  ThePointer.Nullify();
  TheImported.Nullify();
  ThePrimitive.Nullify();
  TheEnum.Nullify();
  TheException.Nullify();
  TheDynType.Nullify();
  TheSimpleClass.Nullify();
  TheClass.Nullify();
  TheStdClass.Nullify();
  TheGenStdClass.Nullify();
  TheError.Nullify();
  TheGenClass.Nullify();
  TheInstClass.Nullify();
  TheEmbeded.Nullify();
  TheMethodName = new TCollection_HAsciiString;
  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheMethodParams.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
  TheMetaSchema.Nullify();
  TheField.Nullify();
  TheParam.Nullify();
  TheParamType = 0;
  TheParamValue.Nullify();
  TheClient.Nullify();
  TheListOfTypes     = new TColStd_HSequenceOfHAsciiString();
  TheListOfPackages  = new TColStd_HSequenceOfHAsciiString();
  TheListOfItem      = new TColStd_HSequenceOfHAsciiString();
  TheListOfName      = new TColStd_HSequenceOfHAsciiString();
  TheListOfCplusplus = new TColStd_HSequenceOfHAsciiString();
  TheListOfComments  = new TColStd_HSequenceOfHAsciiString();
  TheIsEmptyLineInComment = Standard_False;
  TheListOfCPPType   = new TColStd_HSequenceOfInteger();
  TheListOfInteger   = new TColStd_HSequenceOfHAsciiString();
  TheListOfGlobalUsed.Nullify();
  TheListOfGlobalUsed.Nullify();
  TheListOfInst.Nullify();
  TheListOfGen.Nullify();
}

//=======================================================================
//function : CDLerror
//purpose  :
//=======================================================================
extern "C"
{
  void CDLerror (const char* theText)
  {
    extern int CDLlineno;
    //
    // The unix like error declaration
    //
    if (theText == NULL)
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": syntax error..." << endm;
      CDL_InitVariable();
      MS_TraductionError::Raise("Syntax error");
    }
    else
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << theText << endm;
      YY_nb_error++;
    }
  }
// int yyparse();
#ifdef YYDEBUG
  extern int yydebug = 1;
#endif
}

// ////////////////////////////////////////
// Implementation                        //
// ////////////////////////////////////////
void Clear_ListOfItem()
{
  TheListOfItem->Clear();
}

void set_inc_state()
{
  TheSaveState      = TheCurrentEntity;
  TheCurrentEntity = CDL_INCDECL;
}

void restore_state()
{
  TheCurrentEntity = TheSaveState;
}

void Type_Name(char* aName)
{
  strncpy(TheTypeName,aName,THE_MAX_CHAR);
}

//=======================================================================
//function : CheckCommentListIsEmpty
//purpose  :
//=======================================================================
void CheckCommentListIsEmpty (const char* theFunctionName)
{
  if (TheListOfComments->IsEmpty())
  {
    return;
  }

  TCollection_AsciiString aMsg;
  for (Standard_Integer aCommentIter = 1; aCommentIter <= TheListOfComments->Length(); ++aCommentIter)
  {
    Handle(TCollection_HAsciiString)& aComment = TheListOfComments->ChangeValue (aCommentIter);
    aComment->RightAdjust();
    aComment->LeftAdjust();
    aMsg += aComment->String();
    aMsg += "\n";
  }

  if (THE_TO_WARN_LOST_DOCS)
  {
    WarningMsg() << "CDL line " << CDLlineno << " : Documentation lost ("  << theFunctionName << ")\n"
                 << aMsg.ToCString() << endm;
    ++YY_nb_warning;
  }
}

// WARNING : dirty code : look at "Standard_" (but faster than build a string from MS::RootPackageName() + "_")
//
//=======================================================================
//function : VerifyClassUses
//purpose  :
//=======================================================================
Standard_Boolean VerifyClassUses(const Handle(TCollection_HAsciiString)& theTypeName)
{
  if ((TheCurrentEntity == CDL_STDCLASS ||
       TheCurrentEntity == CDL_GENCLASS) &&
      TheCheckUsesForClasses == CDL_MUSTCHECKUSES)
  {
    // WARNING : dirty code -> here is !!! (sorry for future hacker, guilty : CLE)
    //
    if (strncmp("Standard_",theTypeName->ToCString(),9) == 0)
    {
      if (TheMetaSchema->IsDefined(theTypeName))
      {
        TheListOfGlobalUsed->Append(theTypeName);

        return Standard_True;
      }
      else
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                   << "\", line " << CDLlineno << ": "
                   << "The package Standard has no declaration of "
                   << "'" << theTypeName << "'" << endm;
        YY_nb_error++;
        return Standard_True;
      }
    }

    if (theTypeName->IsSameString(TheSimpleClass->FullName())) return  Standard_True;

    if (TheCurrentEntity == CDL_GENCLASS)
    {
      if (theTypeName->IsSameString(TheGenClass->FullName())) return  Standard_True;

      Standard_Integer                        i;
      Handle(TColStd_HSequenceOfHAsciiString) seqascii = TheGenClass->GetNestedName();
      Handle(TCollection_HAsciiString)        nestname,
             nestnestname = new TCollection_HAsciiString();

      if (TheMetaSchema->IsDefined(theTypeName))
      {
        Handle(MS_Type) theType = TheMetaSchema->GetType(theTypeName);

        if (theType->IsKind(STANDARD_TYPE(MS_Class)))
        {
          Handle(MS_Class) inst = *((Handle(MS_Class)*)&theType);

          if (!inst->GetNestingClass().IsNull())
          {
            if (TheGenClass->FullName()->IsSameString(inst->GetNestingClass())) return Standard_True;
            nestnestname = inst->GetNestingClass();
          }
        }
      }

      for (i = 1; i <= seqascii->Length(); i++)
      {
        nestname = MS::BuildFullName(TheContainer,seqascii->Value(i));

        if (theTypeName->IsSameString(nestname) || nestnestname->IsSameString(nestname))
        {
          return Standard_True;
        }
      }

      Handle(MS_HSequenceOfGenType) genericitems = TheGenClass->GenTypes();

      for (i = 1; i <= genericitems->Length(); i++)
      {
        if (genericitems->Value(i)->Name()->IsSameString(theTypeName))
        {
          return Standard_True;
        }
      }
    }

    Handle(TColStd_HSequenceOfHAsciiString) seqOfType = TheSimpleClass->GetUsesNames();

    for (Standard_Integer i = 1; i <= seqOfType->Length(); i++)
    {
      if (seqOfType->Value(i)->IsSameString(theTypeName))
      {
        return Standard_True;
      }
    }

    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
               << "\", line " << CDLlineno << ": "
               << "The 'uses' statement of your class has no declaration of : "
               << theTypeName << endm;
    YY_nb_error++;
  }
  else return Standard_True;

  return Standard_False;
}

//=======================================================================
//function : VerifyUses
//purpose  :
//=======================================================================
Standard_Boolean VerifyUses(char* used)
{
  if (TheCurrentEntity == CDL_PACKAGE ||
      TheCurrentEntity == CDL_INTERFACE ||
      TheCurrentEntity == CDL_EXECUTABLE)
  {
    Handle(TColStd_HSequenceOfHAsciiString)  aSeqOfPackage;
    Handle(MS_Package)                       aPackage;
    Handle(MS_Interface)                     anInterface;
    Handle(MS_Engine)                        anEngine;
    Handle(MS_Component)                     aComponent;
    Standard_Boolean                         status = Standard_False;
    Standard_Integer                         i;

    if (TheMetaSchema->IsPackage(TheContainer))
    {
      aPackage = TheMetaSchema->GetPackage(TheContainer);
      aSeqOfPackage = aPackage->Uses();
    }
    else if (TheMetaSchema->IsInterface(TheContainer))
    {
      anInterface = TheMetaSchema->GetInterface(TheContainer);
      aSeqOfPackage = anInterface->Uses();
    }
    else if (TheMetaSchema->IsEngine(TheContainer))
    {
      anEngine = TheMetaSchema->GetEngine(TheContainer);
      aSeqOfPackage = anEngine->Uses();
    }
    else if (TheMetaSchema->IsComponent(TheContainer))
    {
      aComponent = TheMetaSchema->GetComponent(TheContainer);
      aSeqOfPackage = aComponent->Uses();
    }

    for (i = 1; i <= aSeqOfPackage->Length() && (status == 0); i++)
    {
      if (strcmp(aSeqOfPackage->Value(i)->ToCString(),used) == 0)
      {
        status = Standard_True;
      }
    }

    return status;
  }
  else return Standard_True;
}

void Type_Pack(char* aName)
{
  if (!VerifyUses(aName))
  {
    Handle(TCollection_HAsciiString) msg = new TCollection_HAsciiString("the entity : ");
    msg->AssignCat(aName);
    msg->AssignCat(" is not in the 'uses' clause of ");
    msg->AssignCat(TheContainer);
    CDLerror((char*)msg->ToCString());
  }

  strncpy(ThePackName,aName,THE_MAX_CHAR);
}

char* TypeCompletion(char* aName)
{
  Handle(TColStd_HSequenceOfHAsciiString) aSeqOfPackage;
  Handle(TCollection_HAsciiString)        aFullName = new TCollection_HAsciiString();
  Standard_Integer                        i;

  if (TheCurrentEntity == CDL_GENCLASS || TheCurrentEntity == CDL_STDCLASS)
  {
    Handle(TCollection_HAsciiString) aPackageName, thethetypename = new TCollection_HAsciiString (aName);


    if (TheSimpleClass->Name()->IsSameString(thethetypename))
    {
      return (char*)TheContainer->ToCString();
    }

    aSeqOfPackage = TheSimpleClass->GetUsesNames();
    for (i = 1; i <= aSeqOfPackage->Length(); i++)
    {
      aPackageName = aSeqOfPackage->Value(i)->Token("_");
      if (aSeqOfPackage->Value(i)->IsSameString(MS::BuildFullName(aPackageName,thethetypename)))
      {
        strcpy (ThePackNameFound, aPackageName->ToCString());
        return ThePackNameFound;
      }
    }

    if (TheMetaSchema->IsDefined (MS::BuildFullName (MS::GetPackageRootName(), thethetypename)))
    {
      return (char* )THE_ROOT_PACKAGE;
    }

    if (TheCurrentEntity == CDL_GENCLASS)
    {
      for (i = 1; i <= TheListOfItem->Length(); i++)
      {
        if (strcmp(TheListOfItem->Value(i)->ToCString(),aName) == 0)
        {
          return (char*)THE_DUMMY_PACKAGE_NAME;
        }
      }
    }
  }

  Handle(MS_Package)   aPackage;
  Handle(MS_Interface) anInterface;
  Handle(MS_Engine)    anEngine;
  Handle(MS_Component) aComponent;

  if (TheMetaSchema->IsPackage(TheContainer))
  {
    aPackage = TheMetaSchema->GetPackage(TheContainer);
    aSeqOfPackage = aPackage->Uses();
  }
  else if (TheMetaSchema->IsInterface(TheContainer))
  {
    anInterface = TheMetaSchema->GetInterface(TheContainer);
    aSeqOfPackage = anInterface->Uses();
  }
  else if (TheMetaSchema->IsEngine(TheContainer))
  {
    anEngine = TheMetaSchema->GetEngine(TheContainer);
    aSeqOfPackage = anEngine->Uses();
  }
  else if (TheMetaSchema->IsComponent(TheContainer))
  {
    aComponent = TheMetaSchema->GetComponent(TheContainer);
    aSeqOfPackage = aComponent->Uses();
  }
  else
  {
    aSeqOfPackage = new TColStd_HSequenceOfHAsciiString;
    aSeqOfPackage->Append(MS::GetPackageRootName());
  }

  for (i = 1; i <= aSeqOfPackage->Length(); i++)
  {
    aFullName->AssignCat(aSeqOfPackage->Value(i));
    aFullName->AssignCat("_");
    aFullName->AssignCat(aName);

    if (TheMetaSchema->IsDefined(aFullName))
    {
      return (char*)(aSeqOfPackage->Value(i)->ToCString());
    }

    aFullName->Clear();
  }
  return NULL;
}

void Type_Pack_Blanc()
{
  char* thePackName;

  // we check if we are able to use incomplete declaration
  //
  if (TheCurrentEntity == CDL_PACKAGE ||
      TheCurrentEntity == CDL_INTERFACE ||
      TheCurrentEntity == CDL_EXECUTABLE ||
      TheCurrentEntity == CDL_CLIENT)
  {
    Handle(TCollection_HAsciiString)         aFullName     = new TCollection_HAsciiString;
    aFullName->AssignCat(TheContainer);
    aFullName->AssignCat("_");
    aFullName->AssignCat(TheTypeName);

    if (!TheMetaSchema->IsDefined(aFullName))
    {
      aFullName->Clear();
      aFullName->AssignCat(MS::GetPackageRootName());
      aFullName->AssignCat("_");
      aFullName->AssignCat(TheTypeName);

      if (!TheMetaSchema->IsDefined(aFullName))
      {
        Handle(TCollection_HAsciiString) msg = new TCollection_HAsciiString("the type '");
        msg->AssignCat(TheTypeName);
        msg->AssignCat("' must be followed by a package name.");
        CDLerror((char*)(msg->ToCString()));
      }
    }
  }

  if (TheCurrentEntity != CDL_INCDECL && TheCurrentEntity != CDL_GENTYPE)
  {
    thePackName = TypeCompletion(TheTypeName);

    if (thePackName == NULL)
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "the type '" << TheTypeName << "' is not defined." << endm;
      YY_nb_error++;
    }
    else
    {
      Type_Pack(thePackName);
    }
  }
  else
  {
    Type_Pack((char*)(TheContainer->ToCString()));
  }

}

void Add_Type()
{
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString(ThePackName);
  Handle(TCollection_HAsciiString) athetypename = new TCollection_HAsciiString(TheTypeName);

  TheListOfTypes->Append(athetypename);
  TheListOfPackages->Append(aPackName);
}

void add_documentation (char* theComment)
{
  Handle(TCollection_HAsciiString) aComment     = new TCollection_HAsciiString (theComment);
  Standard_Integer                 aPos         = aComment->Location (1, ':', 1, aComment->Length());
  Handle(TCollection_HAsciiString) aRealComment = aComment->SubString (aPos + 1, aComment->Length());
  aRealComment->RightAdjust();
  aRealComment->LeftAdjust();
  if (aRealComment->String() == ".")
  {
    aRealComment->Clear();
  }
  for (; !aRealComment->IsEmpty()
       && aRealComment->Value (aRealComment->Length()) == '\\'; )
  {
    // should not appear in comments
    aRealComment->Remove (aRealComment->Length());
  }
  if (aRealComment->IsEmpty())
  {
    TheIsEmptyLineInComment = !TheListOfComments->IsEmpty();
    return;
  }

  if (!TheListOfComments->IsEmpty()
   && TheIsEmptyLineInComment)
  {
    TheListOfComments->Append (new TCollection_HAsciiString ("\n//!"));
  }
  TheIsEmptyLineInComment = Standard_False;
  aRealComment->Insert (1, TheListOfComments->IsEmpty() ? "//! " : "\n//! ");
  TheListOfComments->Append (aRealComment);
}

void add_documentation1 (char* theComment)
{
  while (*theComment != '\0'
       && IsSpace (*theComment))
  {
    ++theComment;
  }
  while (*theComment == '-')
  {
    ++theComment;
  }
  if (*theComment == '\0')
  {
    return;
  }

  Handle(TCollection_HAsciiString) aRealComment = new TCollection_HAsciiString (theComment);
  aRealComment->RightAdjust();
  aRealComment->LeftAdjust();
  if (aRealComment->String() == ".")
  {
    aRealComment->Clear();
  }
  for (; !aRealComment->IsEmpty()
       && aRealComment->Value (aRealComment->Length()) == '\\'; )
  {
    // should not appear in comments
    aRealComment->Remove (aRealComment->Length());
  }
  if (aRealComment->IsEmpty())
  {
    TheIsEmptyLineInComment = !TheListOfComments->IsEmpty();
    return;
  }

  if (!TheListOfComments->IsEmpty()
   && TheIsEmptyLineInComment)
  {
    TheListOfComments->Append (new TCollection_HAsciiString ("\n//!"));
  }
  TheIsEmptyLineInComment = Standard_False;
  aRealComment->Insert (1, "\n//! ");
  TheListOfComments->Append (aRealComment);
  TheIsEmptyLineInComment = Standard_False;
}

//=======================================================================
//function : add_cpp_comment
//purpose  :
//=======================================================================
void add_cpp_comment(int cpptype, char* comment)
{
  Handle(TCollection_HAsciiString) aComment;
  Handle(TCollection_HAsciiString) aRealComment;

  if (TheMethod.IsNull())
  {
    WarningMsg() << "CDL" << "line " << CDLlineno \
                 << " : " << "C++ directive outside method definition : "\
                 << comment << endm;
    YY_nb_warning++;
  }
  else
  {
    if (cpptype == CDL_HARDALIAS || cpptype == CDL_OPERATOR)
    {
      Standard_Integer pos;
      aComment = new TCollection_HAsciiString(comment);

      pos = aComment->Location(1,':',1,aComment->Length());
      aRealComment = aComment->SubString(pos + 1,aComment->Length());
      aRealComment->LeftAdjust();
    }

    TheListOfCplusplus->Append(aRealComment);
    TheListOfCPPType->Append(cpptype);
  }
}

//=======================================================================
//function : add_name_to_list
//purpose  :
//=======================================================================
void add_name_to_list(char* name)
{
  Handle(TCollection_HAsciiString) aName =
    new TCollection_HAsciiString(name);

  TheListOfName->Append(aName);
}

//=======================================================================
//function : Begin_List_Int
//purpose  :
//=======================================================================
void Begin_List_Int(char* anInt)
{
  Handle(TCollection_HAsciiString) Int = new TCollection_HAsciiString(anInt);

  TheListOfInteger->Clear();
  TheListOfInteger->Append(Int);
}

void Make_List_Int(char* anInt)
{
  Handle(TCollection_HAsciiString) Int = new TCollection_HAsciiString(anInt);

  TheListOfInteger->Append(Int);
}

// The actions for the Schema
//
void Schema_Begin(char* name)
{
  Handle(TCollection_HAsciiString) aSchemaName = new TCollection_HAsciiString(name);

  TheSchema = new MS_Schema(aSchemaName);
  TheSchema->MetaSchema(TheMetaSchema);
  TheContainer = aSchemaName;

  if (!TheMetaSchema->AddSchema(TheSchema))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Schema : " << aSchemaName << " is already defined." << endm;
    YY_nb_error++;
  }
  CheckCommentListIsEmpty("Schema_Begin");
  TheListOfComments->Clear();
}

void Schema_Package(char* name)
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString) aName = new TCollection_HAsciiString(name);
  TheSchema->Package(aName);
  for(i = 1; i <= TheListOfComments->Length(); i++)
  {
    TheSchema->SetComment(TheListOfComments->Value(i));
  }
  TheListOfComments->Clear();
}

void Schema_Class()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackageName = new TCollection_HAsciiString(ThePackName);

  TheSchema->Class(MS::BuildFullName(aPackageName,aClassName));
}

void Schema_End()
{
  TheSchema.Nullify();
  TheContainer.Nullify();
}

// The actions for the Engine
//
void Engine_Begin(char* engineName)
{
  Handle(TCollection_HAsciiString) anEngineName = new TCollection_HAsciiString(engineName);

  TheEngine = new MS_Engine(anEngineName);
  TheEngine->MetaSchema(TheMetaSchema);
  TheContainer = anEngineName;

  if (!TheMetaSchema->AddEngine(TheEngine))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Engine : " << anEngineName << " is already defined." << endm;
    YY_nb_error++;
  }

  TheEngine->Use(MS::GetPackageRootName());
}

void Engine_Schema(char* name)
{
  Handle(TCollection_HAsciiString) sname = new TCollection_HAsciiString(name);

  TheEngine->Schema(sname);
  TheListOfGlobalUsed->Append(sname);
}

void Engine_Interface(char* inter)
{
  Handle(TCollection_HAsciiString) sname = new TCollection_HAsciiString(inter);

  TheEngine->Interface(sname);
  TheListOfGlobalUsed->Append(sname);
}

void Engine_End()
{
  TheEngine.Nullify();
  TheContainer.Nullify();
}

// The actions for the Component
//
void Component_Begin(char* ComponentName)
{
  Handle(TCollection_HAsciiString) anComponentName = new TCollection_HAsciiString(ComponentName);

  TheComponent = new MS_Component(anComponentName);
  TheComponent->MetaSchema(TheMetaSchema);
  TheContainer = anComponentName;

  if (!TheMetaSchema->AddComponent(TheComponent))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Component : " << anComponentName << " is already defined." << endm;
    YY_nb_error++;
  }

  TheComponent->Use(MS::GetPackageRootName());
}

void Component_Interface(char* inter, char* udname)
{
  Handle(TCollection_HAsciiString) uname = new TCollection_HAsciiString(udname);
  Handle(TCollection_HAsciiString) sname = new TCollection_HAsciiString(inter);

  sname = MS::BuildFullName(uname,sname);
  TheComponent->Interface(sname);
  TheListOfGlobalUsed->Append(sname);
}

void Component_End()
{
  TheComponent.Nullify();
  TheContainer.Nullify();
}

// UD : stub client
//
void Client_Begin(char* clientName)
{
  Handle(TCollection_HAsciiString) aClientName = new TCollection_HAsciiString(clientName);

  TheClient = new MS_Client(aClientName);
  TheClient->MetaSchema(TheMetaSchema);
  TheContainer = aClientName;

  if (!TheMetaSchema->AddClient(TheClient))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Client : " << clientName << " is already defined." << endm;
    YY_nb_error++;
  }

  TheCurrentEntity = CDL_CLIENT;
}

void Client_Interface(char* inter)
{
  Handle(TCollection_HAsciiString) aIName = new TCollection_HAsciiString(inter);

  TheClient->Interface(aIName);
}

void Client_Method(char* entity, int execmode)
{
  if (execmode == 1)
  {
    if (entity != NULL && !TheExternMet.IsNull())
    {
      TheExternMet->Package(new TCollection_HAsciiString(entity));
    }
    TheMethod->Params(TheMethodParams);
    TheMethodParams.Nullify();
    TheMethod->CreateFullName();

    TheClient->Method(TheMethod->FullName());
  }
  else if (execmode < 0)
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "constructor cannot have the asynchronous execution mode." << endm;
    YY_nb_error++;
  }

  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
}


void Client_End()
{
  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
  TheInterface.Nullify();
  TheContainer.Nullify();
  TheClient.Nullify();

  TheCurrentEntity = CDL_NULL;
  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

// The actions for the Executable

void Executable_Begin(char* name)
{
  TheExecutableLanguage = CDL_CPP;
  TheExecutableUseType  = 0;

  Handle(TCollection_HAsciiString) anExecName = new TCollection_HAsciiString(name);

  TheExecutable = new MS_Executable(anExecName);
  TheExecutable->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddExecutable(TheExecutable))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Executable : " << anExecName << " is already defined." << endm;
    YY_nb_error++;
  }

  TheExecTable = new MS_HSequenceOfExecPart;

  TheCurrentEntity = CDL_EXECUTABLE;
}

void ExecFile_Begin(char* name)
{
  TheExecutableLanguage = CDL_CPP;
  TheExecutableUseType  = 0;

  Handle(TCollection_HAsciiString) anExecName = new TCollection_HAsciiString(name);

  TheExecPart = new MS_ExecPart(anExecName);
  TheExecPart->MetaSchema(TheMetaSchema);
  TheExecTable->Append(TheExecPart);
}


void ExecFile_Schema(char* name)
{
  Handle(TCollection_HAsciiString) a = new TCollection_HAsciiString(name);

  TheExecPart->Schema(a);
}

void ExecFile_AddUse(char* name)
{
  Handle(TCollection_HAsciiString) a = new TCollection_HAsciiString(name);

  if (TheExecutableUseType == CDL_LIBRARY)
  {
    TheExecPart->AddLibrary(a);
  }
  else
  {
    TheExecPart->AddExternal(a);
  }
}

void ExecFile_SetUseType(int t)
{
  TheExecutableUseType = t;
}

void ExecFile_AddComponent(char* name)
{
  Handle(TCollection_HAsciiString) a = new TCollection_HAsciiString(name);
  Handle(MS_ExecFile)              aFile;

  aFile = new MS_ExecFile(a);

  switch (TheExecutableLanguage)
  {
    case CDL_CPP:
    default:
      aFile->SetLanguage(MS_CPP);
      break;
    case CDL_FOR:
      aFile->SetLanguage(MS_FORTRAN);
      break;
    case CDL_C:
      aFile->SetLanguage(MS_C);
      break;
    case CDL_OBJ:
      aFile->SetLanguage(MS_OBJECT);
      break;
  }

  TheExecPart->AddFile(aFile);
}

void ExecFile_SetLang(int l)
{
  TheExecutableLanguage = l;
}

void ExecFile_End()
{
  TheExecPart.Nullify();
}

void Executable_End()
{
  TheExecutable->AddParts(TheExecTable);

  TheExecTable.Nullify();
  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
  TheInterface.Nullify();
  TheExecutable.Nullify();
  TheClient.Nullify();

  TheCurrentEntity = CDL_NULL;
  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

// The actions for the Interface

void Interface_Begin(char* anInterName)
{
  Handle(TCollection_HAsciiString) anInterfaceName = new TCollection_HAsciiString(anInterName);

  TheInterface = new MS_Interface(anInterfaceName);
  TheInterface->MetaSchema(TheMetaSchema);
  TheContainer = anInterfaceName;

  if (!TheMetaSchema->AddInterface(TheInterface))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Interface : " << anInterName << " is already defined." << endm;
    YY_nb_error++;
  }

  TheInterface->Use(MS::GetPackageRootName());
  TheCurrentEntity = CDL_INTERFACE;
}

void Interface_Use(char* aPackageName)
{
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString(aPackageName);

  TheListOfGlobalUsed->Append(aPackName);
  TheInterface->Use(aPackName);
}

void Client_Use ( char* aClientName )
{

  Handle( TCollection_HAsciiString ) aCltName =
    new TCollection_HAsciiString ( aClientName );

  TheClient -> Use ( aCltName );

}  // end Client_Use

void Interface_Package(char* aPackageName)
{
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString(aPackageName);

  TheInterface->Package(aPackName);
}

void Interface_Class()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackageName = new TCollection_HAsciiString(ThePackName);

  TheInterface->Class(MS::BuildFullName(aPackageName,aClassName));
  TheListOfGlobalUsed->Append(MS::BuildFullName(aPackageName,aClassName));
}

void Method_TypeName()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackageName = new TCollection_HAsciiString(ThePackName);

  TheListOfGlobalUsed->Append(MS::BuildFullName(aPackageName,aClassName));
}

void Interface_Method(char* entityName)
{
  if (entityName != NULL && !TheExternMet.IsNull())
  {
    TheExternMet->Package(new TCollection_HAsciiString(entityName));
  }

  TheMethod->Params(TheMethodParams);
  TheMethodParams.Nullify();
  TheMethod->CreateFullName();
  TheInterface->Method(TheMethod->FullName());

  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
}

void Interface_End()
{
  TheMethod.Nullify();
  TheMemberMet.Nullify();
  TheExternMet.Nullify();
  TheConstruc.Nullify();
  TheInstMet.Nullify();
  TheClassMet.Nullify();
  TheInterface.Nullify();
  TheContainer.Nullify();
  TheClient.Nullify();

  TheCurrentEntity = CDL_NULL;
  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

// The actions for the Package
//
void Pack_Begin(char* aPackageName)
{
  const Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString (aPackageName);
  TheContainer = aPackName;

  ThePackage = new MS_Package (aPackName);
  ThePackage->MetaSchema (TheMetaSchema);
  for (Standard_Integer i = 1; i <= TheListOfComments->Length(); i++)
  {
    ThePackage->SetComment(TheListOfComments->Value (i));
  }

  if (!TheMetaSchema->AddPackage (ThePackage))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Package : " << aPackageName << " is already defined." << endm;
    YY_nb_error++;
  }
  ThePackage->Use(MS::GetPackageRootName());

  TheCurrentEntity = CDL_PACKAGE;
  TheListOfComments->Clear();

}

void Pack_Use(char* aPackageName)
{
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString (aPackageName);
  for (Standard_Integer i = 1; i <= TheListOfComments->Length(); i++)
  {
    ThePackage->SetComment (TheListOfComments->Value (i));
  }

  TheListOfGlobalUsed->Append (aPackName);
  ThePackage->Use (aPackName);
  TheListOfComments->Clear();
}

void Pack_End()
{
  add_cpp_comment_to_method();
  ThePackage.Nullify();
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  CheckCommentListIsEmpty("Pack_End");
  TheListOfComments->Clear();
}

// The actions for the classes

void Alias_Begin()
{
  Handle(TCollection_HAsciiString) anAliasName = new TCollection_HAsciiString(TheTypeName);

  TheAlias = new MS_Alias(anAliasName,TheContainer,TheContainer,TheIsPrivate);

  TheAlias->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(TheAlias))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Alias : " << TheAlias->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }

  TheIsPrivate = Standard_False;
}

void Alias_Type()
{
  Handle(TCollection_HAsciiString) anAliasName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackageName = new TCollection_HAsciiString(ThePackName);


  TheAlias->Type(anAliasName,aPackageName);
  TheListOfGlobalUsed->Append(TheAlias->Type());
}

void Alias_End()
{
  ThePackage->Alias (TheAlias->Name());
  TheAlias.Nullify();
}

// Pointer type
//
void Pointer_Begin()
{
  Handle(TCollection_HAsciiString) aPointerName = new TCollection_HAsciiString(TheTypeName);

  ThePointer = new MS_Pointer(aPointerName,TheContainer,TheContainer,TheIsPrivate);

  ThePointer->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(ThePointer))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Pointer : " << ThePointer->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }

  TheIsPrivate = Standard_False;
}

void Pointer_Type()
{
  Handle(TCollection_HAsciiString) athetypename = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackageName = new TCollection_HAsciiString(ThePackName);

  ThePointer->Type(athetypename,aPackageName);
  TheListOfGlobalUsed->Append(ThePointer->Type());
}

void Pointer_End()
{
  ThePackage->Pointer (ThePointer->Name());
  ThePointer.Nullify();
}

void Set_HandleClass()
{
  TheIsTransient = Standard_True;
}

void Imported_Begin()
{
  Handle(TCollection_HAsciiString) anImportedName = new TCollection_HAsciiString(TheTypeName);

  TheImported = new MS_Imported(anImportedName,TheContainer,TheContainer,TheIsPrivate);

  TheImported->SetTransient (TheIsTransient);

  TheImported->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(TheImported))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Imported : " << TheImported->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }

  TheIsPrivate   = Standard_False;
  TheIsTransient = Standard_False;
}

void Imported_End()
{
  ThePackage->Imported (TheImported->Name());
  TheImported.Nullify();
  TheIsTransient = Standard_False;
}


void Prim_Begin()
{
  Handle(TCollection_HAsciiString) aPrimName = new TCollection_HAsciiString(TheTypeName);

  ThePrimitive = new MS_PrimType(aPrimName,TheContainer,TheContainer,TheIsPrivate);

  ThePrimitive->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(ThePrimitive))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Primitive : " << ThePrimitive->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }

  TheIsPrivate = Standard_False;
}

void Prim_End()
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString) iName;

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    iName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));

    if (i > 1)
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Type " << ThePrimitive->FullName() << " uses multiple inheritance." << endm;
      YY_nb_error++;
    }
    else if (!iName->IsSameString(ThePrimitive->FullName()))
    {
      ThePrimitive->Inherit(TheListOfTypes->Value(i),TheListOfPackages->Value(i));
    }
    else
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Primitive : " << ThePrimitive->FullName() << " can not inherits from itself." << endm;
      YY_nb_error++;
    }
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();

  ThePackage->Primitive(ThePrimitive->Name());
  ThePrimitive.Nullify();
}


void Except_Begin()
{
  Handle(TCollection_HAsciiString) anExceptName = new TCollection_HAsciiString(TheTypeName);

  TheException = new MS_Error(anExceptName,TheContainer);

  TheException->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(TheException))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Exception : " << TheException->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }
}

void Except_End()
{
  Standard_Integer i;
  Handle(TCollection_HAsciiString) iName;

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    iName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));

    if (i > 1)
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Exception " << TheException->FullName() << " uses multiple inheritance." << endm;
      YY_nb_error++;
    }
    else if (!iName->IsSameString(TheException->FullName()))
    {
      TheException->Inherit(TheListOfTypes->Value(i),TheListOfPackages->Value(i));
    }
    else
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Exception : " << TheException->FullName() << " can not inherits from itself." << endm;
      YY_nb_error++;
    }
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();

  ThePackage->Except (TheException->Name());
  TheException.Nullify();
}

void Inc_Class_Dec()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);

  TheStdClass = new MS_StdClass(aClassName,TheContainer);

  TheStdClass->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->AddType(TheStdClass))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class : " << TheStdClass->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }

  TheStdClass->Private    (TheIsPrivate);
  TheStdClass->Deferred   (TheIsDeferred);
  TheStdClass->Imported   (TheIsImported);
  TheStdClass->Incomplete (Standard_True);
  ThePackage->Class (TheStdClass->Name());
  TheStdClass->Package (ThePackage->FullName());

  TheListOfGlobalUsed->Append(TheStdClass->FullName());

  TheStdClass.Nullify();

  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
  CheckCommentListIsEmpty("Inc_Class_Dec");
  TheListOfComments->Clear();
}

void Inc_GenClass_Dec()
{
  Standard_Integer    i;
  Handle(MS_GenClass) theClass;

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    TheGenClass = new MS_GenClass(TheListOfTypes->Value(i),TheListOfPackages->Value(i));
    TheGenClass->MetaSchema(TheMetaSchema);

    if (i == 1)
    {
      theClass = TheGenClass;
    }
    else
    {
      theClass->AddNested(TheGenClass->Name());
      TheGenClass->Mother(theClass->FullName());
      TheGenClass->NestingClass(theClass->FullName());
    }

    if (!TheMetaSchema->AddType(TheGenClass))
    {
      ErrorMsg() << "CDL" << "\"" << TheCDLFileName->ToCString() << "\"" <<  ", line " << CDLlineno << ": " << "Generic class : " << TheGenClass->FullName() << " is already defined." << endm;
      YY_nb_error++;
    }

    TheGenClass->Private   (TheIsPrivate);
    TheGenClass->Deferred  (TheIsDeferred);
    TheGenClass->Imported  (TheIsImported);
    TheGenClass->Incomplete(Standard_True);

    ThePackage->Class (TheGenClass->Name());
    TheGenClass->Package (ThePackage->FullName());
  }

  TheListOfGen->Append(theClass->FullName());
  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();

  TheGenClass.Nullify();
}

// Generic type processing
//
void GenClass_Begin()
{
  Handle(MS_Package) aPackage;
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName  = new TCollection_HAsciiString(ThePackName);
  Handle(MS_Type)                  aType;

  if (TheCurrentEntity == CDL_GENCLASS)
  {
    aPackName = TheGenClass->Package()->Name();
  }
  else
  {
    TheContainer = aPackName;
  }

  if (!TheMetaSchema->IsPackage(TheContainer))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Unknown package " << TheContainer << endm;
    YY_nb_error++;
    CDL_InitVariable();
    MS_TraductionError::Raise("Unknown package.");
  }

  TheGenClass = new MS_GenClass(aClassName,aPackName);

  if (!TheMetaSchema->IsDefined(TheGenClass->FullName()))
  {
    TheGenClass->MetaSchema(TheMetaSchema);

    TheGenClass->Private   (TheIsPrivate);
    TheGenClass->Deferred  (TheIsDeferred);
    TheGenClass->Imported  (TheIsImported);
    TheGenClass->Incomplete(Standard_False);

    TheMetaSchema->AddType (TheGenClass);
  }
  else
  {
    TheGenClass = Handle(MS_GenClass)::DownCast(TheMetaSchema->GetType(TheGenClass->FullName()));

    if (TheGenClass.IsNull())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class : " << TheGenClass->FullName() << " already declared but not as a generic class." << endm;
      CDL_InitVariable();
      MS_TraductionError::Raise("Class already defined but as generic.");
    }

    if (TheIsPrivate != TheGenClass->Private())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheGenClass->FullName() << " has not the same visibility keyword in package declaration and in class definition." << endm;
      YY_nb_error++;
    }

    if (TheIsImported != TheGenClass->Imported())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheGenClass->FullName() << " has not the same 'imported' keyword in package declaration and in class definition." << endm;
      YY_nb_error++;
    }

    if (TheIsDeferred != TheGenClass->Deferred())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheGenClass->FullName() << " is ";

      if (TheIsDeferred)
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheGenClass->FullName() << " is declared 'deferred' in class definition but not in package declaration." << endm;
      }
      else
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheGenClass->FullName() << " is declared 'deferred' in package declaration but not in class definition." << endm;
      }
      YY_nb_error++;
    }
    TheGenClass->GetNestedName()->Clear();
  }

  TheGenClass->Package(aPackName);

  TheCurrentEntity = CDL_GENCLASS;

  TheSimpleClass = TheGenClass;

  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
  CheckCommentListIsEmpty("GenClass_Begin");
  TheListOfComments->Clear();
}

void Add_GenType()
{
  if (TheIsAny)
  {
    TheGenClass->GenType(TheListOfItem->Value(TheListOfItem->Length()));
    TheIsAny = Standard_False;
  }
  else
  {
    Handle(TCollection_HAsciiString) aTName = new TCollection_HAsciiString(TheTypeName);
    Handle(TCollection_HAsciiString) aPName = new TCollection_HAsciiString(ThePackName);

    TheGenClass->GenType(TheListOfItem->Value(TheListOfItem->Length()),MS::BuildFullName(aPName,aTName));
  }
}

void Add_DynaGenType()
{
  TheGenClass->GenType(TheDynType);

  TheDynType.Nullify();
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}

void Add_Embeded()
{
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}

void GenClass_End()
{
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  Clear_ListOfItem();

  TheGenClass->Incomplete(Standard_False);

  if (!TheStdClass.IsNull())
  {
    TheStdClass->Incomplete(Standard_False);
  }

  TheGenClass.Nullify();
  TheStdClass.Nullify();

  TheCurrentEntity = CDL_NULL;
}


void InstClass_Begin()
{
  Handle(TCollection_HAsciiString) aPackName  = TheContainer;
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  //Standard_Integer i;

  if (TheCurrentEntity == CDL_GENCLASS)
  {
    aPackName  = TheGenClass->Package()->Name();
  }

  if (TheCurrentEntity != CDL_PACKAGE)
  {
    if (!TheMetaSchema->IsPackage(aPackName))
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Package : " << ThePackName << " is not defined." << endm;
      CDL_InitVariable();
      MS_TraductionError::Raise("Package not defined.");
    }
  }


  TheInstClass = new MS_InstClass(aClassName,aPackName);

  if (TheMetaSchema->IsDefined(TheInstClass->FullName()) && TheCurrentEntity == CDL_PACKAGE)
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Instantiation class " << TheInstClass->Name() << " is already declared in package " << aPackName << endm;
    YY_nb_error++;
  }

  TheInstClass->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->IsDefined(TheInstClass->FullName()) || TheCurrentEntity == CDL_GENCLASS)
  {
    if (TheCurrentEntity == CDL_GENCLASS && TheMetaSchema->IsDefined(TheInstClass->FullName()))
    {
      TheMetaSchema->RemoveType(TheInstClass->FullName(),Standard_False);
      TheGenClass->NestedInsClass(TheInstClass->Name());
      TheInstClass->Mother(TheGenClass->FullName());
    }
    else if (TheCurrentEntity == CDL_GENCLASS)
    {
      Handle(MS_Package) aPackage = TheMetaSchema->GetPackage(aPackName);

      if (!aPackage->HasClass(aClassName))
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Nested instantiation class : " << TheInstClass->Name() << " is not declared in package " << aPackName << endm;
        YY_nb_error++;
        CDL_InitVariable();
        MS_TraductionError::Raise("Instantiation not defined.");
      }
    }

    if (TheCurrentEntity == CDL_GENCLASS)
    {
      TheInstClass->NestingClass(TheGenClass->FullName());
      TheGenClass->AddNested(TheInstClass->Name());
    }

    TheInstClass->MetaSchema(TheMetaSchema);
    TheInstClass->Package   (aPackName);
    TheInstClass->Private   (TheIsPrivate);

    TheMetaSchema->AddType (TheInstClass);
    TheIsPrivate = Standard_False;
  }
  else
  {
    Handle(MS_Type) aType = TheMetaSchema->GetType(TheInstClass->FullName());

    TheInstClass = Handle(MS_InstClass)::DownCast(aType);

    if (TheInstClass.IsNull())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "The instantiation " << aClassName << " was not declared..." << endm;
      YY_nb_error++;
      CDL_InitVariable();
      MS_TraductionError::Raise("Instantiation not defined.");
    }
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  CheckCommentListIsEmpty("InstClass_Begin");
  TheListOfComments->Clear();
}

void Add_Gen_Class()
{
  Handle(TCollection_HAsciiString) aPackName  = new TCollection_HAsciiString(ThePackName);
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);

  TheInstClass->GenClass(aClassName,aPackName);
}

void Add_InstType()
{
  Standard_Integer                 i;
  Handle(MS_Type)                  aType;
  Handle(TCollection_HAsciiString) aFullName;
  Standard_Boolean                 ComeFromDynaType = Standard_False;

  if (TheCurrentEntity == CDL_GENTYPE)
  {
    ComeFromDynaType = Standard_True;
    restore_state();
  }

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    aFullName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));

    if (TheMetaSchema->IsDefined(aFullName))
    {
      aType = TheMetaSchema->GetType(aFullName);
    }
    else
    {
      char* aTypeName = TypeCompletion ((char*)(TheListOfTypes->Value(i)->ToCString()));
      if (aTypeName == THE_DUMMY_PACKAGE_NAME)
      {
        TheListOfPackages->Value (i)->Clear();
      }
    }

    if (!ComeFromDynaType)
    {
      TheInstClass->InstType(TheListOfTypes->Value(i),TheListOfPackages->Value(i));
    }
    else
    {
      if (TheListOfPackages->Value(i)->IsEmpty())
      {
        TheDynType->InstType(TheListOfTypes->Value(i));
      }
      else
      {
        TheDynType->InstType(MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i)));
      }
    }
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}

void InstClass_End()
{
  if (TheCurrentEntity == CDL_GENCLASS)
  {
    TheInstClass->Instantiates();
  }
  else  if (TheCurrentEntity == CDL_PACKAGE)
  {
    ThePackage->Class(TheInstClass->Name());
  }

  if (TheCurrentEntity != CDL_GENCLASS)
  {
    TheListOfInst->Append(TheInstClass->FullName());
  }


  TheInstClass->Incomplete(Standard_False);
  TheListOfGen->Append (TheInstClass->GenClass());
  TheInstClass.Nullify();
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();


  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

void DynaType_Begin()
{
  Handle(MS_Package)                       aPackage;
  Handle(TColStd_HSequenceOfHAsciiString)  aSeqOfPackage;

  TheSaveState      = TheCurrentEntity;
  TheCurrentEntity = CDL_GENTYPE;

  if (!TheListOfItem->IsEmpty())
  {
    Standard_Integer i;
    Handle(TCollection_HAsciiString) aPackName;
    Handle(TCollection_HAsciiString) aGenName  = new TCollection_HAsciiString(TheTypeName);

    if (strcmp (THE_DUMMY_PACKAGE_NAME, ThePackName))
    {
      aPackName = new TCollection_HAsciiString (ThePackName);
    }
    else
    {
      aPackage = TheMetaSchema->GetPackage (TheContainer);
      aSeqOfPackage = aPackage->Uses();

      for (i = 1; i <= aSeqOfPackage->Length(); i++)
      {
        if (TheMetaSchema->IsDefined(MS::BuildFullName(aSeqOfPackage->Value(i),aGenName)))
        {
          aPackName = aSeqOfPackage->Value(i);
        }
      }

      if (aPackName.IsNull())
      {
        aPackName = new TCollection_HAsciiString();
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "constraint type " << TheTypeName << " comes from a package not declared in 'uses' clause of the package " << TheContainer << endm;
        YY_nb_error++;
      }
    }

    TheDynType = new MS_GenType(TheGenClass,TheListOfItem->Value(TheListOfItem->Length()),MS::BuildFullName(aPackName,aGenName));
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}


void StdClass_Begin()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName  = new TCollection_HAsciiString(ThePackName);
  Standard_Integer i;

  if (TheCurrentEntity == CDL_GENCLASS)
  {
    aPackName  = TheGenClass->Package()->Name();
  }

  TheContainer  = aPackName;

  if (!TheMetaSchema->IsPackage(TheContainer))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Unknown package " << TheContainer << endm;
    YY_nb_error++;
    CDL_InitVariable();
    MS_TraductionError::Raise("Unknown package.");
  }
  // si la classe n a pas ete cree par une dec incomplete
  //
  TheStdClass = new MS_StdClass(aClassName,aPackName);
  TheStdClass->MetaSchema(TheMetaSchema);

  if (!TheMetaSchema->IsDefined(TheStdClass->FullName()) || TheCurrentEntity == CDL_GENCLASS)
  {
    if (TheCurrentEntity == CDL_GENCLASS && TheMetaSchema->IsDefined(TheStdClass->FullName()))
    {
      TheMetaSchema->RemoveType(TheStdClass->FullName(),Standard_False);
      TheGenClass->NestedStdClass(TheStdClass->Name());
      TheStdClass->Mother(TheGenClass->FullName());
    }
    else if (TheCurrentEntity == CDL_GENCLASS)
    {
      Handle(MS_Package) aPackage = TheMetaSchema->GetPackage(aPackName);

      if (!aPackage->HasClass(aClassName))
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class : " << TheStdClass->Name() << " is not declared in package " << aPackName << endm;
        YY_nb_error++;
        CDL_InitVariable();
        MS_TraductionError::Raise("Class not defined.");
      }
      TheGenClass->NestedStdClass(TheStdClass->Name());
      TheStdClass->Mother(TheGenClass->FullName());
    }

    if (TheCurrentEntity == CDL_GENCLASS)
    {
      TheStdClass->SetGenericState(Standard_True);
      TheStdClass->NestingClass(TheGenClass->FullName());
      TheGenClass->AddNested(TheStdClass->Name());
    }

    TheStdClass->MetaSchema (TheMetaSchema);
    TheStdClass->Private    (TheIsPrivate);
    TheStdClass->Deferred   (TheIsDeferred);
    TheStdClass->Imported   (TheIsImported);
    TheStdClass->Incomplete (Standard_False);

    TheMetaSchema->AddType (TheStdClass);

    TheStdClass->Package (aPackName);
  }
  else
  {
    Handle(MS_Type) aType = TheMetaSchema->GetType(TheStdClass->FullName());

    TheStdClass = Handle(MS_StdClass)::DownCast(aType);

    if (TheStdClass.IsNull())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "The class " << aClassName << " was not declared..." << endm;
      CDL_InitVariable();
      MS_TraductionError::Raise("Class not defined.");
    }

    if (TheIsPrivate != TheStdClass->Private())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheStdClass->FullName() << " has not the same visibility keyword in package declaration and in class definition." << endm;
      YY_nb_error++;
    }

    if (TheIsImported != TheStdClass->Imported())
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheStdClass->FullName() << " has not the same 'imported' keyword in package declaration and in class definition." << endm;
      YY_nb_error++;
    }

    if (TheIsDeferred != TheStdClass->Deferred())
    {
      if (TheIsDeferred)
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheStdClass->FullName() << " is declared 'deferred' in class definition but not in package declaration." << endm;
      }
      else
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheStdClass->FullName() << " is declared 'deferred' in package declaration but not in class definition." << endm;
      }
      YY_nb_error++;
    }
  }

  if (TheCurrentEntity != CDL_GENCLASS)
  {
    TheCurrentEntity = CDL_STDCLASS;
  }
  for (i =1; i <= TheListOfComments->Length(); i++)
  {
    TheStdClass->SetComment(TheListOfComments->Value(i));
  }

  TheSimpleClass = TheStdClass;

  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  TheListOfComments->Clear();

}

void Add_Std_Ancestors()
{
  Handle(TCollection_HAsciiString) aFullName;
  for (Standard_Integer i = 1; i <= TheListOfTypes->Length(); i++)
  {
    aFullName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));

    if (TheMetaSchema->IsDefined(aFullName))
    {
      Handle(MS_Class) aClass = Handle(MS_Class)::DownCast(TheMetaSchema->GetType(aFullName));
      if (aClass.IsNull())
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class : " << aFullName << " must not be a normal class." << endm;
        YY_nb_error++;
      }

      if (i > 1)
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheSimpleClass->FullName() << " uses multiple inheritance." << endm;
        YY_nb_error++;
      }
      else if (!TheSimpleClass->FullName()->IsSameString(aClass->FullName()))
      {
        TheSimpleClass->Inherit(aClass);
      }
      else
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class " << TheSimpleClass->FullName() << " can not inherits from itself." << endm;
        YY_nb_error++;
      }

      TheSimpleClass->Use(TheListOfTypes->Value(i),TheListOfPackages->Value(i));

      TheListOfGlobalUsed->Append(aFullName);
    }
    else
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Class : " << aFullName << " not defined, can't be in inherits clause." << endm;
      YY_nb_error++;
    }
  }
  //TheSimpleClass->MetaSchema(TheMetaSchema);
  for (Standard_Integer i = 1; i <= TheListOfComments->Length(); i++)
  {
    TheSimpleClass->SetComment(TheListOfComments->Value(i));
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  TheListOfComments->Clear();
}

void Add_Std_Uses()
{
  Standard_Integer  i;


  //TheSimpleClass->MetaSchema(TheMetaSchema);
  for (i =1; i <= TheListOfComments->Length(); i++)
  {
    TheSimpleClass->SetComment(TheListOfComments->Value(i));
  }

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    Handle(TCollection_HAsciiString) aFullName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));

    if (TheCurrentEntity != CDL_GENCLASS && !TheMetaSchema->IsDefined(aFullName))
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "The 'uses' statement of your class has a type : " << aFullName << " from a package not declared in the 'uses' statement of the package " << TheContainer << endm;
      YY_nb_error++;
    }
    else if (TheCurrentEntity != CDL_GENCLASS)
    {
      if (!TheSimpleClass->Package()->IsUsed(TheListOfPackages->Value(i)))
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "The 'uses' statement of your class has a type : " << aFullName << " from a package not declared in the 'uses' statement of the package " << TheContainer << endm;
        YY_nb_error++;
      }
    }

    TheSimpleClass->Use(TheListOfTypes->Value(i),TheListOfPackages->Value(i));

    TheListOfGlobalUsed->Append(aFullName);
  }

  TheListOfComments->Clear();
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}

void StdClass_End()
{
  if (TheCurrentEntity == CDL_GENCLASS)
  {
    TheSimpleClass = TheGenClass;
  }

  TheStdClass->Incomplete(Standard_False);

  TheStdClass.Nullify();
  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
  TheListOfComments->Clear();
}


void Add_Raises()
{
  Standard_Integer i;

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    Handle(TCollection_HAsciiString) aFullName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));
    if (TheMetaSchema->IsDefined(aFullName))
    {
      TheSimpleClass->Raises(TheListOfTypes->Value(i),TheListOfPackages->Value(i));
    }
    else
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "the exception "  << "'" << aFullName << "'" << " is not defined."  << endm;
      YY_nb_error++;
    }
  }

  TheListOfTypes->Clear();
  TheListOfPackages->Clear();
}

void Add_Field()
{
  Standard_Integer i,j;
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName  = new TCollection_HAsciiString(ThePackName);

  for (i = 1; i <= TheListOfName->Length(); i++)
  {
    TheField = new MS_Field(TheSimpleClass,TheListOfName->Value(i));

    TheField->MetaSchema(TheMetaSchema);

    for (j = 1; j <= TheListOfInteger->Length(); j++)
    {
      TheField->Dimension(TheListOfInteger->Value(j)->IntegerValue());
    }

    if (strcmp (ThePackName, THE_DUMMY_PACKAGE_NAME) == 0)
    {
      aPackName->Clear();
    }
    else
    {
      VerifyClassUses(MS::BuildFullName(aPackName,aClassName));
    }

    TheField->TYpe (aClassName, aPackName);


    TheField->Protected (TheIsProtected);

    TheSimpleClass->Field (TheField);
  }

  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheListOfInteger->Clear();
  TheListOfName->Clear();
}

void Add_RedefField()
{
  ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Fields redefinition no more supported..." << endm;
  YY_nb_error++;
}

void Add_FriendMet()
{
  TheMethod->Params(TheMethodParams);
  TheMethodParams.Nullify();
  TheMethod->CreateFullName();
  TheSimpleClass->FriendMet(TheMethod->FullName());
}

void Add_FriendExtMet(char* aPackName)
{
  Handle(TCollection_HAsciiString) apack = new TCollection_HAsciiString(aPackName);

  TheExternMet->Package(apack);
  TheMethod->Params(TheMethodParams);
  TheMethodParams.Nullify();
  TheMethod->CreateFullName();
  TheSimpleClass->FriendMet(TheMethod->FullName());
}

//=======================================================================
//function : Add_Friend_Class
//purpose  :
//=======================================================================
void Add_Friend_Class()
{
  Handle(TCollection_HAsciiString) aClassName = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName  = new TCollection_HAsciiString(ThePackName);
  Handle(TCollection_HAsciiString) theTypeName = MS::BuildFullName(aPackName,aClassName);

  if (TheMetaSchema->IsDefined(theTypeName))
  {
    TheSimpleClass->Friend(aClassName,aPackName);
    TheListOfGlobalUsed->Append(theTypeName);
  }
  else
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "friend class " << theTypeName->ToCString() << " is not defined." << endm;
    YY_nb_error++;
  }
}

WOKTools_MapOfHAsciiString anEnumMap;

// The actions for the Enumeration
//
//=======================================================================
//function : Enum_Begin
//purpose  :
//=======================================================================
void Enum_Begin()
{
  Handle(TCollection_HAsciiString) anEnumName = new TCollection_HAsciiString(TheTypeName);

  anEnumMap.Clear();

  TheEnum = new MS_Enum(anEnumName,TheContainer,TheContainer,TheIsPrivate);

  TheEnum->MetaSchema(TheMetaSchema);
  TheEnum->Package (ThePackage->FullName());

  CheckCommentListIsEmpty("Enum_Begin");
  TheListOfComments->Clear();

  if (!TheMetaSchema->AddType(TheEnum))
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Enumeration : " << TheEnum->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }
}


void Add_Enum(char* aValue)
{
  Handle(TCollection_HAsciiString) anEnumValue = new TCollection_HAsciiString(aValue);
  for(Standard_Integer i = 1; i <= TheListOfComments->Length(); i++)
  {
    TheEnum->SetComment(TheListOfComments->Value(i));
  }
  TheListOfComments->Clear();

  if (!anEnumMap.Contains(anEnumValue))
  {
    anEnumMap.Add(anEnumValue);
    TheEnum->Enum(anEnumValue);
  }
  else
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "Enumeration value " << aValue << " in " << TheEnum->FullName() << " is already defined." << endm;
    YY_nb_error++;
  }
}

void Enum_End()
{
  //Enum->Check();
  ThePackage->Enum(TheEnum->Name());
  for(Standard_Integer i = 1; i <= TheListOfComments->Length(); i++)
  {
    TheEnum->SetComment(TheListOfComments->Value(i));
  }
  TheListOfComments->Clear();
  TheEnum.Nullify();
  anEnumMap.Clear();

  TheIsPrivate   = Standard_False;
}

// The actions for the Methods
//
void get_cpp_commentalias(const Handle(TCollection_HAsciiString)& aComment)
{
  Handle(TCollection_HAsciiString) aToken1,
         aToken2;

  aToken1 = aComment->Token();

  aToken1->LeftAdjust();
  aToken1->RightAdjust();

  aComment->Remove(1,aToken1->Length());
  aComment->LeftAdjust();
  aComment->RightAdjust();
}

//=======================================================================
//function : add_cpp_comment_to_method
//purpose  :
//=======================================================================
void add_cpp_comment_to_method()
{
  if (TheMethod.IsNull())
  {
    if (TheListOfCplusplus->Length() > 0)
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                 << "\", line " << CDLlineno << ": "
                 << "C++ directive outside method definition." << endm;
      YY_nb_error++;
    }
  }
  else
  {
    Standard_Boolean isFirst = Standard_True;
    for (Standard_Integer aLineIter = 1; aLineIter <= TheListOfComments->Length(); ++aLineIter)
    {
      Handle(TCollection_HAsciiString) aLine = TheListOfComments->ChangeValue (aLineIter);
      aLine->Insert (aLine->Value (1) != '\n' ? 1 : 2, isFirst ? "\n  " : "  ");
      TheMethod->SetComment (aLine);
      isFirst = Standard_False;
    }
    TheListOfComments->Clear();

    Handle(TCollection_HAsciiString) aCP;
    const Standard_Integer aNbCPP = TheListOfCplusplus->Length();
    for(Standard_Integer i = 1; i <= aNbCPP; ++i)
    {
      Standard_Integer aCommentType = TheListOfCPPType->Value(i);
      //
      switch (aCommentType)
      {
        case CDL_HARDALIAS:
          get_cpp_commentalias(TheListOfCplusplus->Value(i));
          TheMethod->Alias(TheListOfCplusplus->Value(i));
          TheMethod->SetAliasType(Standard_False);
          break;
        case CDL_OPERATOR:
          get_cpp_commentalias(TheListOfCplusplus->Value(i));
          TheMethod->Alias(TheListOfCplusplus->Value(i));
          TheMethod->SetAliasType(Standard_True);
          break;
        case CDL_INLINE:
          TheMethod->Inline(Standard_True);
          break;
        case CDL_DESTRUCTOR:
          if (TheMethod->IsFunctionCall())
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'alias ~' cannot be used with 'function call'."
                       << endm;
            YY_nb_error++;
          }
          TheMethod->Destructor(Standard_True);
          break;

        case CDL_CONSTREF:
          if (!TheMethod->Returns().IsNull())
          {
            TheMethod->ConstReturn(Standard_True);
            TheMethod->RefReturn(Standard_True);
          }
          else
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'return const &' cannot be used without 'returns' clause."
                       << endm;
            YY_nb_error++;
          }
          break;
        case CDL_REF:
          if (!TheMethod->Returns().IsNull())
          {
            TheMethod->RefReturn(Standard_True);
          }
          else
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'return &' cannot be used without 'returns' clause."
                       << endm;
            YY_nb_error++;
          }
          break;
          //===f
        case CDL_CONSTPTR:
          if (!TheMethod->Returns().IsNull())
          {
            TheMethod->ConstReturn(Standard_True);
            TheMethod->PtrReturn(Standard_True);
          }
          else
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'return const &' cannot be used without 'returns' clause."
                       << endm;
            YY_nb_error++;
          }
          break;
        case CDL_PTR:
          if (!TheMethod->Returns().IsNull())
          {
            TheMethod->PtrReturn(Standard_True);
          }
          else
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'return &' cannot be used without 'returns' clause." << endm;
            YY_nb_error++;
          }
          break;
          //===t
        case CDL_CONSTRET:
          if (!TheMethod->Returns().IsNull())
          {
            TheMethod->ConstReturn(Standard_True);
          }
          else
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'return const' cannot be used without 'returns' clause." << endm;
            YY_nb_error++;
          }
          break;
        case CDL_FUNCTIONCALL:
          if (TheMethod->IsDestructor())
          {
            ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString()
                       << "\", line " << TheMethodLineNo << ": "
                       << "C++ directive 'function call' cannot be used with 'alias ~'." << endm;
            YY_nb_error++;
          }
          TheMethod->FunctionCall(Standard_True);
          break;
        default:
          break;
      }
    }

    //
    CheckCommentListIsEmpty("add_cpp_comment_to_method");
    TheListOfComments->Clear();
    TheListOfCplusplus->Clear();
    TheListOfCPPType->Clear();
    TheMetaSchema->AddMethod(TheMethod);
  }
}

//=======================================================================
//function : Construct_Begin
//purpose  :
//=======================================================================
void Construct_Begin()
{
  if (TheSimpleClass->Deferred())
  {
    if (!TheMethodName->IsSameString(TheDefCons))
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A deferred class must not have a constructor with name 'Create' or no 'me' or 'myclass' present for the method." << endm;
      YY_nb_error++;
    }
  }
  else
  {
    if (!TheMethodName->IsSameString(TheNorCons))
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A class must have a constructor with name 'Create' or no 'me' or 'myclass' present for the method." << endm;
      YY_nb_error++;
    }
  }

  if (!TheMethod.IsNull())
  {
    add_cpp_comment_to_method();
  }
  TheMethodLineNo = CDLlineno;
  TheConstruc  = new MS_Construc(TheMethodName,TheSimpleClass->FullName());
  TheMethod    = TheConstruc;
  TheMemberMet = TheConstruc;
  TheMethod->MetaSchema(TheMetaSchema);
}

void Friend_Construct_Begin()
{
  TheConstruc  = new MS_Construc(TheMethodName,TheListOfGlobalUsed->Value(TheListOfGlobalUsed->Length()));
  TheMethod    = TheConstruc;
  TheMemberMet = TheConstruc;
  TheMethod->MetaSchema(TheMetaSchema);
}

void InstMet_Begin()
{
  if (!TheMethod.IsNull())
  {
    add_cpp_comment_to_method();
  }
  TheMethodLineNo = CDLlineno;
  TheInstMet   = new MS_InstMet(TheMethodName,TheSimpleClass->FullName());
  TheMethod    = TheInstMet;
  TheMethod->MetaSchema(TheMetaSchema);
  TheMemberMet = TheInstMet;
}

void Friend_InstMet_Begin()
{
  TheInstMet   = new MS_InstMet(TheMethodName,TheListOfGlobalUsed->Value(TheListOfGlobalUsed->Length()));
  TheMethod    = TheInstMet;
  TheMemberMet = TheInstMet;
  TheMethod->MetaSchema(TheMetaSchema);
}

void ClassMet_Begin()
{
  if (!TheMethod.IsNull())
  {
    add_cpp_comment_to_method();
  }
  TheMethodLineNo = CDLlineno;
  TheClassMet  = new MS_ClassMet(TheMethodName,TheSimpleClass->FullName());
  TheMethod    = TheClassMet;
  TheMethod->MetaSchema(TheMetaSchema);
  TheMemberMet = TheClassMet;
}

void Friend_ClassMet_Begin()
{
  TheClassMet  = new MS_ClassMet(TheMethodName,TheListOfGlobalUsed->Value(TheListOfGlobalUsed->Length()));
  TheMethod    = TheClassMet;
  TheMemberMet = TheClassMet;
  TheMethod->MetaSchema(TheMetaSchema);
}

void ExtMet_Begin()
{
  if (!TheMethod.IsNull())
  {
    add_cpp_comment_to_method();
  }
  TheMethodLineNo = CDLlineno;
  TheExternMet = new MS_ExternMet (TheMethodName, ThePackage->Name());
  TheMethod    = TheExternMet;
  TheMethod->MetaSchema(TheMetaSchema);
}

void Friend_ExtMet_Begin()
{
  TheExternMet = new MS_ExternMet(TheMethodName);
  TheMethod    = TheExternMet;
  TheMethod->MetaSchema(TheMetaSchema);
}

void Add_Me()
{
  if (TheMutable == MS_MUTABLE)
  {
    TheInstMet->ConstMode(MSINSTMET_MUTABLE);
  }
  else if (TheInOrOut == MS_INOUT || TheInOrOut == MS_OUT)
  {
    TheInstMet->ConstMode(MSINSTMET_OUT);
  }
  else
  {
    TheInstMet->Const(Standard_True);
  }

  TheMutable = 0;
  TheInOrOut = MS_IN;
}

void Add_MetRaises()
{
  Standard_Integer                 i,j;
  Handle(TCollection_HAsciiString) aName;

  for (i = 1; i <= TheListOfTypes->Length(); i++)
  {
    aName = MS::BuildFullName(TheListOfPackages->Value(i),TheListOfTypes->Value(i));
    if (TheMetaSchema->IsDefined(aName))
    {
      if (TheCurrentEntity == CDL_STDCLASS || TheCurrentEntity == CDL_GENCLASS)
      {
        Handle(TColStd_HSequenceOfHAsciiString) seq = TheSimpleClass->GetRaises();
        Standard_Boolean isFound = Standard_False;

        for (j = 1; j <= seq->Length() && !isFound; j++)
        {
          if (seq->Value(j)->IsSameString(aName))
          {
            isFound = Standard_True;
          }
        }

        if (!isFound)
        {
          ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "the exception "  << "'" << aName << "'" << " is not declared in 'raises' clause of the class: " << TheSimpleClass->FullName() << endm;
          YY_nb_error++;
        }
        else
        {
          TheMethod->Raises(aName);
        }
      }
      else
      {
        TheMethod->Raises(aName);
      }
    }
    else
    {
      // si on est dans les methodes de package on ne verifie pas les raises
      //
      if (TheExternMet.IsNull())
      {
        ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "the exception "  << "'" << aName << "'" << " is not defined."  << endm;
        YY_nb_error++;
      }
      else
      {
        TheMethod->Raises(aName);
      }
    }
  }

  TheListOfPackages->Clear();
  TheListOfTypes->Clear();
}

void Add_Returns()
{
  Handle(TCollection_HAsciiString) athetypename = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString(ThePackName);
  Handle(MS_Param)                 aParam;
  Standard_Boolean                 isGenType = Standard_False;

  aParam = new MS_Param(TheMethod,athetypename);

  aParam->Like       (TheIsLike);
  aParam->AccessMode (TheMutable);
  aParam->AccessMode (TheInOrOut);
  aParam->MetaSchema (TheMetaSchema);

  if (strcmp (ThePackName, THE_DUMMY_PACKAGE_NAME) == 0)
  {
    aPackName->Clear();
    isGenType = Standard_True;
  }
  else
  {
    VerifyClassUses(MS::BuildFullName(aPackName,athetypename));
  }


  aParam->Type(athetypename,aPackName);

  if (!TheConstruc.IsNull())
  {
    if (!aParam->TypeName()->IsSameString(TheConstruc->Class()))
    {
      ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "The constructor must return " << TheConstruc->Class() << " not " << aParam->TypeName() << endm;
      YY_nb_error++;
    }
  }

  TheMethod->Returns(aParam);

  TheMutable = 0;
  TheInOrOut = MS_IN;
  TheIsLike      = Standard_False;

  TheListOfName->Clear();
}

void MemberMet_End()
{
  TheSimpleClass->Method(TheMemberMet);
  TheMethod->Params(TheMethodParams);
  TheMethodParams.Nullify();
  TheMemberMet->CreateFullName();
  TheMemberMet->Private  (TheIsPrivate);
  TheMemberMet->Protected(TheIsProtected);

  if (!TheInstMet.IsNull())
  {
    TheInstMet->Deferred (TheIsDeferred);
    TheInstMet->Redefined(TheIsRedefined);
    TheInstMet->Static   (TheIsStatic);
  }

  TheMemberMet.Nullify();
  TheInstMet.Nullify();
  TheConstruc.Nullify();
  TheClassMet.Nullify();

  TheIsPrivate   = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

void ExternMet_End()
{
  ThePackage->Method (TheExternMet);
  TheMethod->Params(TheMethodParams);
  TheMethodParams.Nullify();
  TheExternMet->CreateFullName();
  TheExternMet->Private (TheIsPrivate);
  TheExternMet.Nullify();
  TheIsPrivate = Standard_False;
  TheIsProtected = Standard_False;
  TheIsStatic    = Standard_True;
  TheIsDeferred  = Standard_False;
  TheIsImported  = Standard_False;
  TheIsTransient = Standard_False;
  TheIsRedefined = Standard_False;
  TheIsLike      = Standard_False;
}

// The actions for Parameters
//
void Param_Begin()
{
  Standard_Integer                 i;
  Handle(MS_Param)                 aParam;
  Handle(TCollection_HAsciiString) athetypename = new TCollection_HAsciiString(TheTypeName);
  Handle(TCollection_HAsciiString) aPackName = new TCollection_HAsciiString(ThePackName);
  Standard_Boolean                 isGenType = Standard_False;

  for (i = 1; i <= TheListOfName->Length(); i++)
  {
    if (TheParamValue.IsNull())
    {
      aParam = new MS_Param(TheMethod,TheListOfName->Value(i));
    }
    else
    {
      aParam = new MS_ParamWithValue(TheMethod,TheListOfName->Value(i));
    }

    aParam->AccessMode(TheMutable);
    aParam->AccessMode(TheInOrOut);
    aParam->MetaSchema(TheMetaSchema);

    if (strcmp (ThePackName, THE_DUMMY_PACKAGE_NAME) == 0)
    {
      aPackName->Clear();
      isGenType = Standard_True;
    }
    else
    {
      VerifyClassUses(MS::BuildFullName(aPackName,athetypename));
    }

    aParam->Like (TheIsLike);
    aParam->Type (athetypename, aPackName);

    if (!TheParamValue.IsNull())
    {
      MS_TypeOfValue pt = MS_INTEGER;
      MS_ParamWithValue* pwv;

      switch (TheParamType)
      {
        case INTEGER:
          break;
        case REAL:
          pt = MS_REAL;
          break;
        case STRING:
          pt = MS_STRING;
          break;
        case LITERAL:
          pt = MS_CHAR;
          break;
        case IDENTIFIER:
          pt = MS_ENUM;
          break;
        default:
          ErrorMsg() << "CDL" << "\"" << TheCDLFileName->ToCString() << "\"" <<  ", line " << CDLlineno << ": " << "Type of default value unknown." << endm;
          YY_nb_error++;
          break;
      }

      pwv = (MS_ParamWithValue*)aParam.operator->();
      pwv->Value(TheParamValue,pt);
    }

    //TheMethod->Param(aParam);
    if(TheMethodParams.IsNull()) TheMethodParams = new MS_HSequenceOfParam;
    TheMethodParams->Append(aParam);
  }

  TheParamValue.Nullify();
  TheMutable = 0;
  TheInOrOut = MS_IN;
  TheIsLike = Standard_False;

  TheListOfName->Clear();
}

void Add_Value(char* str,int type)
{
  TheParamValue = new TCollection_HAsciiString(str);
  TheParamType  = type;
}


// The general actions
//
void End()
{

}

void Set_In()
{
  TheInOrOut = MS_IN;
}

void Set_Out()
{
  TheInOrOut = MS_OUT;
}

void Set_InOut()
{
  TheInOrOut = MS_INOUT;
}

void Set_Mutable()
{
  TheMutable = MS_MUTABLE;
}

void Set_Mutable_Any()
{
  TheMutable = MS_ANY;
}

void Set_Immutable()
{
  TheMutable = MS_IMMUTABLE;
}

void Set_Priv()
{
  TheIsPrivate = Standard_True;
}

void Set_Defe()
{
  TheIsDeferred = Standard_True;
}

void Set_Imported()
{
  TheIsImported = Standard_True;
}

void Set_Redefined()
{
  if (!TheConstruc.IsNull())
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A constructor cannot be redefined." << endm;
    YY_nb_error++;
  }
  if (!TheClassMet.IsNull())
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A class method cannot be redefined." << endm;
    YY_nb_error++;
  }
  TheIsRedefined = Standard_True;
  TheIsStatic    = Standard_False;
}

void Set_Prot()
{
  TheIsProtected = Standard_True;
  TheIsPrivate   = Standard_False;
}

void Set_Static()
{
  TheIsStatic = Standard_True;
}

void Set_Virtual()
{
  if (!TheClassMet.IsNull())
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A class method cannot be redefined, so the 'virtual' keyword cannot be applied to " << TheClassMet->Name() << endm;
    YY_nb_error++;
  }
  if (!TheConstruc.IsNull())
  {
    ErrorMsg() << "CDL\"" << TheCDLFileName->ToCString() << "\", line " << CDLlineno << ": " << "A constructor cannot be redefined, so the 'virtual' keyword cannot be applied to it." << endm;
    YY_nb_error++;
  }
  TheIsStatic = Standard_False;
}

void Set_Method(char* name)
{
  TheMethodName = new TCollection_HAsciiString(name);
}

void Set_Like_Me()
{
  TheIsLike = Standard_True;

  strncpy(TheTypeName,TheSimpleClass->Name()->ToCString(),THE_MAX_CHAR);
  strncpy(ThePackName,TheContainer->ToCString(),THE_MAX_CHAR);
}

void Set_Like_Type()
{
  ErrorMsg() << "CDL" << "\"" << TheCDLFileName->ToCString() << "\"" <<  ", line " << CDLlineno << ": Obsolete syntaxe : like <TheTypeName>" << endm;
  YY_nb_error++;
}

void Set_Item(char* Item)
{
  Handle(TCollection_HAsciiString) anItem = new TCollection_HAsciiString(Item);

  TheListOfItem->Append(anItem);
}

void Set_Any()
{
  TheIsAny = Standard_True;
}


extern "C" int CDLparse();


void CDL_Main()
{
  YY_nb_error = 0;
  CDLparse();
}

extern "C" {
  void CDLrestart(FILE*);
}

int TraductionMain(char* FileName)
{

  CDLin = fopen(FileName,"r");



  if (CDLin == NULL)
  {
    CDL_InitVariable();
    ErrorMsg() << "CDL" << " File not found : " << FileName << endm;
    MS_TraductionError::Raise("File not found.");
  }

  CDLrestart(CDLin);
  // Boot file
  //
  CDL_Main();

  fclose(CDLin);

  if (YY_nb_error > 0)
  {
    ErrorMsg() << "CDL" << YY_nb_error << " errors." << endm;
  }

  if (YY_nb_warning > 0)
  {
    WarningMsg() << "CDL" << YY_nb_warning << " warnings." << endm;
  }

  return YY_nb_error;
}



int CDLTranslate(const Handle(MS_MetaSchema)&             aMetaSchema,
                 const Handle(TCollection_HAsciiString)&  aFileName,
                 const Handle(TColStd_HSequenceOfHAsciiString)& aGlobalList,
                 const Handle(TColStd_HSequenceOfHAsciiString)& aTypeList,
                 const Handle(TColStd_HSequenceOfHAsciiString)& anInstList,
                 const Handle(TColStd_HSequenceOfHAsciiString)& anGenList)
{
  volatile Standard_Integer  ErrorLevel = 0;

  CDL_InitVariable();

  TheMetaSchema    = aMetaSchema;
  TheListOfGlobalUsed = aGlobalList;
  TheListOfGlobalUsed   = aTypeList;
  TheListOfInst       = anInstList;
  TheListOfGen        = anGenList;

  if (!aFileName.IsNull())
  {
    CDLlineno = 1;
    TheCDLFileName = aFileName;

    try {
      OCC_CATCH_SIGNALS
      ErrorLevel = TraductionMain((char*)(aFileName->ToCString()));
    }
    catch(Standard_Failure)
    {
      fclose(CDLin);
      ErrorLevel = 1;
    }
  }
  else
  {
    ErrorLevel = 1;
  }

  TheMetaSchema.Nullify();
  TheListOfGlobalUsed.Nullify();
  TheListOfGlobalUsed.Nullify();
  TheListOfInst.Nullify();
  TheListOfGen.Nullify();
  TheListOfComments.Nullify();
  return ErrorLevel;
}
