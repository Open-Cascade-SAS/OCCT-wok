// File modified by jga for Visul C++ 5.0
//
#ifndef _WOKTclTools_Interpretor_HeaderFile
#define _WOKTclTools_Interpretor_HeaderFile

#include <Handle_WOKTclTools_Interpretor.hxx>

#include <Standard_Boolean.hxx>
#include <WOKTclTools_PInterp.hxx>
#include <MMgt_TShared.hxx>
#include <Standard_CString.hxx>
#include <WOKTclTools_CommandFunction.hxx>
#include <WOKTclTools_WokCommand.hxx>
#include <WOKTclTools_ExitHandler.hxx>
#include <Standard_Integer.hxx>
#include <Standard_Real.hxx>
#include <Standard_Character.hxx>
class WOKTools_Return;


class WOKTclTools_Interpretor : public MMgt_TShared {

public:

  // Methods PUBLIC
  // 
  Standard_EXPORT WOKTclTools_Interpretor();
  Standard_EXPORT WOKTclTools_Interpretor(const WOKTclTools_PInterp& anInterp);
  Standard_EXPORT   void Add(const Standard_CString Command,const Standard_CString Help,const WOKTclTools_CommandFunction Function,const Standard_CString Group = "User Commands") ;
  Standard_EXPORT   void Add(const Standard_CString Command,const Standard_CString Help,const WOKTclTools_WokCommand Function,const Standard_CString Group = "User Commands") ;
  Standard_EXPORT   void AddExitHandler(const WOKTclTools_ExitHandler Function) ;
  Standard_EXPORT   void DeleteExitHandler(const WOKTclTools_ExitHandler Function) ;
  Standard_EXPORT   Standard_Boolean IsCmdName(const Standard_CString Command) ;
  Standard_EXPORT   Standard_Boolean Remove(const Standard_CString Command) ;
  Standard_EXPORT   Standard_Integer PkgProvide(const Standard_CString aname,const Standard_CString aversion) ;
  Standard_EXPORT   Standard_Integer TreatReturn(const WOKTools_Return& values) ;
  Standard_EXPORT   Standard_CString Result() const;
  Standard_EXPORT   Standard_Boolean GetReturnValues(WOKTools_Return& retval) const;
  Standard_EXPORT   void Reset() ;
  Standard_EXPORT   void Append(const Standard_CString Result) ;
  Standard_EXPORT   void Append(const Standard_Integer Result) ;
  Standard_EXPORT   void Append(const Standard_Real Result) ;
  Standard_EXPORT   void AppendElement(const Standard_CString Result) ;
  Standard_EXPORT   Standard_Integer Eval(const Standard_CString Script) ;
  Standard_EXPORT   Standard_Integer RecordAndEval(const Standard_CString Script,const Standard_Integer Flags = 0) ;
  Standard_EXPORT   Standard_Integer EvalFile(const Standard_CString FileName) ;
  Standard_EXPORT static  Standard_Boolean Complete(const Standard_CString Script) ;
  Standard_EXPORT   void Destroy() ;
  ~WOKTclTools_Interpretor()
    {
      Destroy();
    }

  Standard_EXPORT   void Set(const WOKTclTools_PInterp& anInterp) ;
  Standard_EXPORT   WOKTclTools_PInterp Interp() const;
  Standard_EXPORT static  Handle_WOKTclTools_Interpretor& Current() ;
  Standard_EXPORT static  void SetEndMessageProc(const Standard_CString aproc) ;
  Standard_EXPORT static  void UnSetEndMessageProc() ;
  Standard_EXPORT static  Standard_CString& EndMessageProc() ;
  Standard_EXPORT static  void SetEndMessageArgs(const Standard_CString aArgs) ;
  Standard_EXPORT static  void UnSetEndMessageArgs() ;
  Standard_EXPORT static  Standard_CString& EndMessageArgs() ;
  Standard_EXPORT   void TreatMessage(const Standard_Boolean newline,const Standard_Character atype,const Standard_CString amsg) const;

  // Type management
  //
  friend Standard_EXPORT Handle_Standard_Type& WOKTclTools_Interpretor_Type_();
  Standard_EXPORT const Handle(Standard_Type)& DynamicType() const;
  Standard_EXPORT Standard_Boolean	       IsKind(const Handle(Standard_Type)&) const;

private: 

  // Fields PRIVATE
  //
  Standard_Boolean isAllocated;
  WOKTclTools_PInterp myInterp;


};

#endif
