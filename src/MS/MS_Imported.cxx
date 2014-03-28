#include <MS_Imported.ixx>

MS_Imported::MS_Imported(const Handle(TCollection_HAsciiString)& aName, 
			 const Handle(TCollection_HAsciiString)& aPackage, 
			 const Handle(TCollection_HAsciiString)& aContainer, 
			 const Standard_Boolean aPrivate)
: MS_NatType(aName,aPackage,aContainer,aPrivate),
  myIsTransient (Standard_False)
{
}

Standard_Boolean MS_Imported::IsTransient() const
{
  return myIsTransient;
}

void MS_Imported::SetTransient (const Standard_Boolean theValue)
{
  myIsTransient = theValue;
}
