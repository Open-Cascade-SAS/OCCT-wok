static const char* sccsid = "@(#)WOKTools_BasicMapIterator.cxx	3.2 95/01/10"; // Do not delete this line. Used by sccs.
// File:	WOKTools_BasicMapIterator.cxx
// Created:	Fri Feb 26 15:46:25 1993
// Author:	Remi LEQUETTE
//		<rle@phylox>


#include <WOKTools_BasicMapIterator.ixx>
#include <WOKTools_BasicMap.hxx>

//=======================================================================
//function : WOKTools_BasicMapIterator
//purpose  : 
//=======================================================================

WOKTools_BasicMapIterator::WOKTools_BasicMapIterator () :
       myNbBuckets(0),
       myBuckets(NULL),
       myBucket(0),
       myNode(NULL)
{}


//=======================================================================
//function : WOKTools_BasicMapIterator
//purpose  : 
//=======================================================================

WOKTools_BasicMapIterator::WOKTools_BasicMapIterator 
  (const WOKTools_BasicMap& M) :
  myNbBuckets(M.myNbBuckets),
  myBuckets(M.myData1),
  myBucket(-1),
  myNode(NULL)
{
  if (!myBuckets) myNbBuckets = -1;
  Next();
}

//=======================================================================
//function : Initialize
//purpose  : 
//=======================================================================

void WOKTools_BasicMapIterator::Initialize
  (const WOKTools_BasicMap& M)
{
  myNbBuckets = M.myNbBuckets;
  myBuckets = M.myData1;
  myBucket = -1;
  myNode = NULL;
  if (!myBuckets) myNbBuckets = -1;
  Next();
}

//=======================================================================
//function : Reset
//purpose  : 
//=======================================================================

void WOKTools_BasicMapIterator::Reset()
{
  myBucket = -1;
  myNode = NULL;
  Next();
}

//=======================================================================
//function : Next
//purpose  : 
//=======================================================================

void WOKTools_BasicMapIterator::Next()
{
  if (!myBuckets) return; 

  if (myNode) {
    myNode = ((WOKTools_MapNode*) myNode)->next;
    if (myNode) return;
  }

  while (!myNode) {
    myBucket++;
    if (myBucket > myNbBuckets) return;
    myNode = ((void**)myBuckets)[myBucket];
  }
}

