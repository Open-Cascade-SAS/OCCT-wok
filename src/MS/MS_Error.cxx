#include <MS_Error.ixx>
#include <Standard_NullObject.hxx>

MS_Error::MS_Error(const Handle(TCollection_HAsciiString)& aName, 
		   const Handle(TCollection_HAsciiString)& aPackage) : MS_StdClass(aName,aPackage)
{
  Incomplete(Standard_False);
}

//void MS_Error::Validity(const Handle(TCollection_HAsciiString)& aName, const Handle(TCollection_HAsciiString)& aPackage) const 
void MS_Error::Validity(const Handle(TCollection_HAsciiString)& , const Handle(TCollection_HAsciiString)& ) const 
{
}

