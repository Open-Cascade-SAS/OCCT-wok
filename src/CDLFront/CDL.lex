/*======================================================*/
/*== CDL lexical analyzer.                              */
/*======================================================*/

%{

#include <string.h>
#include <stdio.h>
#ifdef WNT
# include <io.h>
#else
# include <unistd.h>
#endif  /* WNT */

#include <cdl_defines.hxx>
void add_cpp_comment(int,char*);
#define yylval CDLlval
#include <CDL.tab.h>
int CDLlineno;

#ifndef YY_NO_UNPUT
# define YY_NO_UNPUT
#endif  /* YY_NO_UNPUT */

extern void CDLerror ( char* );

%}


/* The specials key words */

COMMENTER	[-][-]
FCPLUSPLUS      [-][-][-][C][+][+][ \t]*
CPLUSPLUS       [-][-][-][C][+][+][ \t]*[:][ \t]*
FCPLUSPLUSD     [-][-][-][C][+][+][ \t]*[2][.][0][ \t]*
CPLUSPLUSD      [-][-][-][C][+][+][ \t]*[2][.][0][ \t]*[:][ \t]*
FCPLUSPLUSD1    [-][-][-][C][+][+][ \t]*[2][.][1][ \t]*
CPLUSPLUSD1     [-][-][-][C][+][+][ \t]*[2][.][1][ \t]*[:][ \t]*
OPERATOR        [-][-][-][C][+][+][ \t]*[:][ \t]*[a][l][i][a][s][ \t]*[o][p][e][r][a][t][o][r]
INLINE          [-][-][-][C][+][+][ \t]*[:][ \t]*[i][n][l][i][n][e][ \t]*
DESTRUCTOR      [-][-][-][C][+][+][ \t]*[:][ \t]*[a][l][i][a][s][ \t]*['~'][ \t]*
CONSTREF        [-][-][-][C][+][+][ \t]*[:][ \t]*[r][e][t][u][r][n][ \t]*[c][o][n][s][t][ \t]*['&'][ \t]*
CONSTRET        [-][-][-][C][+][+][ \t]*[:][ \t]*[r][e][t][u][r][n][ \t]*[c][o][n][s][t][ \t]*
REF             [-][-][-][C][+][+][ \t]*[:][ \t]*[r][e][t][u][r][n][ \t]*['&'][ \t]*
HARDALIAS       [-][-][-][C][+][+][ \t]*[:][ \t]*[a][l][i][a][s][ \t]*\"(\\\"|[^"])*\"[ \t]*
FUNCTIONCALL    [-][-][-][C][+][+][ \t]*[:][ \t]*[f][u][n][c][t][i][o][n][ \t]*[c][a][l][l][ \t]*

/* The identifiers without underscore at begining and end */

IDENTIFIER	[A-Za-z][A-Za-z0-9_]*[A-Za-z0-9]


/* Integer and real */

INTEGER		[+-]?[0-9]+
REAL		[+-]?[0-9]+"."[0-9]+([Ee][+-]?[0-9]+)?

/* Literal and string */

LITERAL 	"'"."'"
STRING		\"(\\\"|[^"])*\"

/* The LEX directives. */

/* %p		5000  */
/* %a		9000  */
/* %o		10000 */

/* The rules section execfile	{ return(execfile); }*/

%%

{REF}\n          { add_cpp_comment(CDL_REF,CDLtext); CDLlineno++; }
{CONSTREF}\n     { add_cpp_comment(CDL_CONSTREF,CDLtext); CDLlineno++; }
{CONSTRET}\n     { add_cpp_comment(CDL_CONSTRET,CDLtext); CDLlineno++; }
{DESTRUCTOR}\n   { add_cpp_comment(CDL_DESTRUCTOR,CDLtext); CDLlineno++; }
{INLINE}\n       { add_cpp_comment(CDL_INLINE,CDLtext); CDLlineno++; }
{OPERATOR}.*\n   { add_cpp_comment(CDL_OPERATOR,CDLtext); CDLlineno++; }
{HARDALIAS}\n    { add_cpp_comment(CDL_HARDALIAS,CDLtext); CDLlineno++; }
{FUNCTIONCALL}\n { add_cpp_comment(CDL_FUNCTIONCALL,CDLtext); CDLlineno++; }
{CPLUSPLUSD}.*\n    { CDLlineno++; CDLerror("C++2.0 directive no more supported."); } 
{FCPLUSPLUSD}.*\n   { CDLlineno++; CDLerror("C++2.0 directive no more supported (':' missing)."); } 
{CPLUSPLUSD1}.*\n   { CDLlineno++; CDLerror("C++2.1 directive no more supported."); } 
{FCPLUSPLUSD1}.*\n  { CDLlineno++; CDLerror("C++2.1 directive no more supported (':' missing)."); } 
{CPLUSPLUS}\n       { CDLlineno++; CDLerror("Empty C++ directive."); } 
{FCPLUSPLUS}.*\n    { CDLlineno++; CDLerror("C++ directive without ':'."); } 
{COMMENTER}.*\n	 { CDLlineno++; }


alias		{ return(alias); }
any		{ return(any); }
asynchronous    { return(asynchronous); }
as		{ return(as); }
class		{ return(class); }
client          { return(client); }
component       { return(component); }
deferred  	{ return(deferred); }
schema  	{ return(schema); }
end		{ return(end); }
engine		{ return(engine); }
enumeration	{ return(enumeration); }
exception	{ return(exception); }
executable	{ return(executable); }
fields		{ return(fields); }
friends		{ return(friends); }
from		{ return(CDL_from); }
generic		{ return(generic); }
immutable	{ return(immutable); }
imported	{ return(imported); }
in		{ return(in); }
inherits	{ return(inherits); }
instantiates	{ return(instantiates); }
interface	{ return(interface); }
is		{ return(is); }
like		{ return(like); }
me		{ return(me); }
mutable		{ return(mutable); }
myclass		{ return(myclass); }
out		{ return(out); }
package		{ return(package); }
pointer		{ return(pointer); }
private		{ return(private); }
primitive	{ return(primitive); }
protected	{ return(protected); }
raises 		{ return(raises); }
redefined	{ return(redefined); }
returns		{ return(returns); }
static		{ return(statiC); }
to 		{ return(CDL_to); }
uses		{ return(uses); }
virtual         { return(virtual); }
library	        { return(library); }
external	{ return(external); }
as[ \t]*[c][+][+]       { return(cpp); }
as[ \t]*c	{ return(krc); }
as[ \t]*fortran         { return(fortran); }
as[ \t]*object          { return(object); }

{IDENTIFIER} |
[A-Za-z]	{ strncpy(CDLlval.str,CDLtext,MAX_CHAR);
		  return(IDENTIFIER); }

{INTEGER}	{ strncpy (CDLlval.str,CDLtext,MAX_CHAR);
		  return(INTEGER); }

{REAL}		{ strncpy(CDLlval.str,CDLtext,MAX_CHAR);
		  return(REAL); }


{LITERAL}	{ strncpy(CDLlval.str,CDLtext,MAX_CHAR);
		  return(LITERAL); }

{STRING}	{ strncpy(CDLlval.str,CDLtext,MAX_STRING);
		  return(STRING) ;}

;		{ return(';'); }
:		{ return(':'); }
"("		{ return('('); }
")"		{ return(')'); }
","		{ return(','); }
"["		{ return('['); }
"]"		{ return(']'); }
"="		{ return('='); }

[ \t]		{ /* We don't take care of line feed, space or tabulation */ }
[\n]            { CDLlineno++; }
.		{ return(INVALID); }

%%
/*
static char comment[MAX_COMMENT + 1];
static int  comment_nb = 0;
static int  new_comment = 0;

 Returns the last identifier 

static Comment()
{
  int size;
  size = strlen(CDLtext);
  if(comment_nb <= MAX_COMMENT - (size+1)) {



     strcpy(&comment[comment_nb],CDLtext);
     comment_nb += size;
     new_comment = 1;
  }
}

 Returns the last identifier 
static EndComment()
{
  int size;
  size = strlen(ENDOFCOMMENT);
  if(new_comment && (comment_nb <= MAX_COMMENT - (size+1))) {



     strcpy(&comment[comment_nb], ENDOFCOMMENT);
     comment_nb += size;
     new_comment = 0;
  }
}
*/

/* Returns the last identifier */

char* YYident(){
 return NULL;
}

/* Returns the last integer */

char* YYinteger(){
 return NULL;
}

/* Returns the last real */

char* YYreal(){
 return NULL;
}

/* Returns the last literal */

char* YYliteral(){
 return NULL;
}

/* Returns the last String */

char* YYstring(){
 return NULL;
}

/* Returns the last comment 

char* YYcomment(){

	comment[comment_nb] = 0;
	comment_nb = 0;     	
	return(comment);
}
*/

int CDLwrap()
{
 return 1;
}

