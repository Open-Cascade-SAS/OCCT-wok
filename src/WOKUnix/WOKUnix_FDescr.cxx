
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>


#ifdef SOLARIS
#include <sys/filio.h>
#else 
#include <sys/ioctl.h>
#endif
#include <fcntl.h>

#include <WOKUnix_FDescr.ixx>

#include <WOKTools_Messages.hxx>

#include <OSD_Protection.hxx>
#include <OSD_OSDError.hxx>
#include <Standard_ProgramError.hxx>

extern "C" { extern int  mknod (const char *, mode_t , dev_t ); }

extern int errno;

const OSD_WhoAmI Iam = OSD_WFile;

//=======================================================================
//function : WOKUnix_FDescr
//purpose  : 
//=======================================================================
WOKUnix_FDescr::WOKUnix_FDescr()
{
  myFILE=NULL;
}

//=======================================================================
//function : WOKUnix_FDescr
//purpose  : 
//=======================================================================
WOKUnix_FDescr::WOKUnix_FDescr(const Standard_Integer afd) {myFileChannel = afd;myFILE = fdopen(afd, "r");}

//=======================================================================
//function : WOKUnix_FDescr
//purpose  : 
//=======================================================================
WOKUnix_FDescr::WOKUnix_FDescr(const Standard_Integer afd, const Handle(TCollection_HAsciiString)& apath)
{
  myFileChannel = afd;
  myFILE = fdopen(afd, "r");
  SetPath(apath->String());
}

//=======================================================================
//function : WOKUnix_FDescr
//purpose  : 
//=======================================================================
WOKUnix_FDescr::WOKUnix_FDescr(const Handle(TCollection_HAsciiString)& apath)
{
  SetPath(apath->String());
  myFILE = NULL;
}

//=======================================================================
//function : EmptyAndOpen
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::EmptyAndOpen()
{
  fclose((FILE *)myFILE);
  close(myFileChannel);
  myFileChannel = open(Name()->ToCString(), 
		       O_RDWR | O_CREAT | O_TRUNC, 
		       S_IRUSR|S_IWUSR|S_IWUSR|S_IRGRP|S_IROTH);

  myFILE = fdopen(myFileChannel, "r");
}

//=======================================================================
//function : GetNbToRead
//purpose  : 
//=======================================================================
Standard_Integer WOKUnix_FDescr::GetNbToRead()  
{
  Standard_Integer nbtoread = 0;
  if(ioctl(myFileChannel, FIONREAD, &nbtoread) < 0)
    {
      Perror();
      return -1;
    }
  return nbtoread;
}

//=======================================================================
//function : SetUnBuffered
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::SetUnBuffered()  
{
  if(fcntl(myFileChannel, F_SETFL, O_SYNC) < 0)
    {
      Perror();
      return;
    }
  return;
}

//=======================================================================
//function : BuildTemporary
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::BuildTemporary()  
{

 char *name = tmpnam((char*) 0) ;

 TCollection_AsciiString aName ( name ) ;
 OSD_Path aPath( aName ) ;

 SetPath( aPath ) ;

 Build(OSD_ReadWrite , OSD_Protection());
 SetUnBuffered();

}

//=======================================================================
//function : BuildTemporary
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::BuildTemporary(const TCollection_AsciiString & apath)  
{
  TCollection_AsciiString astr(apath);
  
  astr.AssignCat("/WOKXXXXXX");

  char *name = mktemp(astr.ToCString()) ;

  TCollection_AsciiString aName ( name ) ;
  OSD_Path aPath( aName ) ;
  
  SetPath( aPath ) ;

  Build(OSD_ReadWrite, OSD_Protection());
  SetUnBuffered();

}

//=======================================================================
//function : BuildNamedPipe
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::BuildNamedPipe()  
{
  TCollection_AsciiString apath;
  WOKUnix_FDescr         writeend;

  apath = tmpnam(NULL);
  SetPath(OSD_Path(apath));

  if(mknod(apath.ToCString(), 0700 |  S_IFIFO, 0)) 
    { perror(apath.ToCString());}

  myFileChannel = open(apath.ToCString(),  O_RDONLY | O_NDELAY | O_CREAT);
  SetUnBuffered();

  // write end of pipe is unbuffered also 
  writeend.SetPath(OSD_Path(Name()->String()));
  writeend.Open(OSD_WriteOnly, OSD_Protection());
  writeend.SetUnBuffered();
  
}

//=======================================================================
//function : SetNonBlock
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::SetNonBlock()  
{
  if(fcntl(myFileChannel, F_SETFL, O_NONBLOCK) < 0)
    {
      Perror();
      return;
    }
  return;
}

//=======================================================================
//function : Flush
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::Flush()  
{
  if(fsync(myFileChannel) < 0)
    {
      Perror();
    }
  return;
}

//=======================================================================
//function : Dup
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::Dup()  
{
  dup(myFileChannel);
}

//=======================================================================
//function : FileNo
//purpose  : 
//=======================================================================
Standard_Integer WOKUnix_FDescr::FileNo() const
{
  return myFileChannel;
}

//=======================================================================
//function : GetSize
//purpose  : 
//=======================================================================
Standard_Integer WOKUnix_FDescr::GetSize()
{
  struct stat buffer;
  Handle(TCollection_HAsciiString) aname;
  int status;
  
  aname = Name();

  if (aname->Length()==0)
    Standard_ProgramError::Raise("OSD_File::Size : empty file name");
  
  if(FileNo() == -1)
    {
      // si le fichier n;est pas ouvert pas le choix
      status = stat( aname->ToCString() ,&buffer );
    }
  else
    {
       // si le fichier n;est pas ouvert pas le choix
      status = fstat( FileNo() ,&buffer );
    }     
  if (status == -1) 
    {
      myError.SetValue (errno, Iam, "Size");
      return (-1);
    }
  
  return ( buffer.st_size );
  
}

//=======================================================================
//function : Name
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKUnix_FDescr::Name() const
{
  OSD_Path apath;
  TCollection_AsciiString astring;

  Path(apath);

  apath.SystemName(astring);
  
  return new TCollection_HAsciiString(astring);
}

//=======================================================================
//function : ReadLine
//purpose  : 
//=======================================================================
Handle(TCollection_HAsciiString) WOKUnix_FDescr::ReadLine() 
{
  Handle(TCollection_HAsciiString) astr;

  if(myFILE == NULL)
    {
      TCollection_AsciiString abuf;
      Standard_Integer nbread = 0;

      while(IsAtEnd() == Standard_False)
	{
	  OSD_File::ReadLine(abuf, 1024, nbread);
	  if(astr.IsNull() && nbread < 1024)
	    {
	      astr = new TCollection_HAsciiString(abuf.ToCString());
	      return astr;
	    }
	  if(astr.IsNull() && nbread == 1024)
	    {
	      astr = new TCollection_HAsciiString(abuf.ToCString());
	    }
	  else if (!astr.IsNull() &&  nbread < 1024)
	    {
	      astr->AssignCat(abuf.ToCString());
	      return astr;
	    }
	  else // !astr.IsNull() &&  nbread == 1024
	    {
	      astr->AssignCat(abuf.ToCString());
	    }
	}
    }
  else
    {
      TCollection_AsciiString abuf;
      Standard_Integer nbread = 0;

      while(GetNbToRead() != 0)
	{
	  fgets(abuf.ToCString(), 1024, (FILE *) myFILE);
	  nbread = strlen(abuf.ToCString());
	  if(astr.IsNull() && nbread < 1024)
	    {
	      astr = new TCollection_HAsciiString(abuf.ToCString());
	      return astr;
	    }
	  if(astr.IsNull() && nbread == 1024)
	    {
	      astr = new TCollection_HAsciiString(abuf.ToCString());
	    }
	  else if (!astr.IsNull() &&  nbread < 1024)
	    {
	      astr->AssignCat(abuf.ToCString());
	      return astr;
	    }
	  else // !astr.IsNull() &&  nbread == 1024
	    {
	      astr->AssignCat(abuf.ToCString());
	    }
	}
    }
  return astr;
}


//=======================================================================
//function : Pipe
//purpose  : 
//=======================================================================
void WOKUnix_FDescr::Pipe(WOKUnix_FDescr &anin, WOKUnix_FDescr &anout)
{
  Standard_Integer in[2];

  if(pipe(in))  
    {
      OSD_OSDError::Raise("WOKUnix_FDescr::Pipe : pipe system call Failed");
    }

  anin = WOKUnix_FDescr(in[1]);
  anout = WOKUnix_FDescr(in[0]);

  return;
}

//=======================================================================
//function : Stdin
//purpose  : 
//=======================================================================
WOKUnix_FDescr WOKUnix_FDescr::Stdin()
{
  static WOKUnix_FDescr StdinFD(0, new TCollection_HAsciiString("/dev/null/stdin"));

  return StdinFD;
}

//=======================================================================
//function : Stdout
//purpose  : 
//=======================================================================
WOKUnix_FDescr WOKUnix_FDescr::Stdout()
{
  static WOKUnix_FDescr StdoutFD(1, new TCollection_HAsciiString("/dev/null/stdout"));

  return StdoutFD;
}

//=======================================================================
//function : Stderr
//purpose  : 
//=======================================================================
WOKUnix_FDescr WOKUnix_FDescr::Stderr()
{
  static WOKUnix_FDescr StderrFD(2, new TCollection_HAsciiString("/dev/null/stderr"));

  return StderrFD;
}






