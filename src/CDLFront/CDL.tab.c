
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.4.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Copy the first part of user declarations.  */

/* Line 189 of yacc.c  */
#line 9 "cdl.yacc"

/* all parser must define this variable */

#define yyparse CDLparse
#define yylex CDLlex
#define yyerror CDLerror
#define yylval CDLlval
#define yychar CDLchar
#define yydebug CDLdebug
#define yynerrs CDLnerrs

#define yyv CDLv

#define MAX_CHAR     256              /* The limit of a identifier.  */
#define MAX_STRING   (MAX_CHAR * 10)  /* The limit of a string.      */
#define MAX_COMMENT  (MAX_CHAR * 300) /* The limit of comment line   */
#define ENDOFCOMMENT "\n%\n"          /* The marque of end of coment */

#define CDL_CPP      1
#define CDL_FOR      2
#define CDL_C        3
#define CDL_OBJ      4
#define CDL_LIBRARY  5
#define CDL_EXTERNAL 6

#include <stdlib.h>
#include <cdl_rules.h>

extern void CDLerror ( const char* );
extern int  CDLlex   ( void  );



/* Line 189 of yacc.c  */
#line 107 "cdl.tab.c"

/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     krc = 258,
     cpp = 259,
     fortran = 260,
     object = 261,
     library = 262,
     external = 263,
     alias = 264,
     any = 265,
     asynchronous = 266,
     as = 267,
     class = 268,
     client = 269,
     component = 270,
     deferred = 271,
     schema = 272,
     end = 273,
     engine = 274,
     enumeration = 275,
     exception = 276,
     executable = 277,
     execfile = 278,
     extends = 279,
     fields = 280,
     friends = 281,
     CDL_from = 282,
     generic = 283,
     immutable = 284,
     imported = 285,
     in = 286,
     inherits = 287,
     instantiates = 288,
     interface = 289,
     is = 290,
     like = 291,
     me = 292,
     mutable = 293,
     myclass = 294,
     out = 295,
     package = 296,
     pointer = 297,
     private = 298,
     primitive = 299,
     protected = 300,
     raises = 301,
     redefined = 302,
     returns = 303,
     statiC = 304,
     CDL_to = 305,
     uses = 306,
     virtual = 307,
     IDENTIFIER = 308,
     JAVAIDENTIFIER = 309,
     INTEGER = 310,
     LITERAL = 311,
     REAL = 312,
     STRING = 313,
     INVALID = 314,
     DOCU = 315
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 214 of yacc.c  */
#line 109 "cdl.yacc"

 char str[MAX_STRING];



/* Line 214 of yacc.c  */
#line 209 "cdl.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */


/* Line 264 of yacc.c  */
#line 221 "cdl.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int yyi)
#else
static int
YYID (yyi)
    int yyi;
#endif
{
  return yyi;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)				\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack_alloc, Stack, yysize);			\
	Stack = &yyptr->Stack_alloc;					\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  48
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   708

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  69
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  254
/* YYNRULES -- Number of rules.  */
#define YYNRULES  406
/* YYNRULES -- Number of states.  */
#define YYNSTATES  717

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   315

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      54,    53,     2,     2,    59,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    57,    58,
       2,    60,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    56,     2,    55,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    61,    62,
      63,    64,    65,    66,    67,    68
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    12,    14,    16,    18,
      20,    22,    24,    26,    28,    30,    31,    41,    43,    45,
      47,    49,    52,    54,    58,    61,    62,    73,    75,    77,
      79,    81,    84,    86,    90,    92,    94,    96,    99,   103,
     108,   111,   114,   115,   121,   127,   130,   133,   136,   138,
     141,   142,   151,   153,   155,   157,   159,   161,   163,   166,
     170,   174,   175,   186,   188,   190,   192,   194,   198,   200,
     202,   204,   206,   208,   211,   215,   216,   225,   227,   229,
     231,   233,   235,   237,   240,   246,   247,   257,   259,   261,
     263,   266,   268,   272,   274,   276,   278,   280,   282,   284,
     287,   291,   295,   296,   302,   308,   316,   319,   324,   327,
     332,   335,   340,   342,   345,   346,   355,   357,   359,   361,
     363,   365,   368,   369,   380,   382,   384,   386,   388,   392,
     394,   397,   399,   403,   407,   409,   411,   413,   415,   417,
     420,   424,   426,   428,   430,   432,   434,   436,   438,   440,
     442,   445,   447,   451,   453,   455,   457,   459,   461,   463,
     465,   467,   471,   473,   477,   479,   481,   483,   485,   489,
     491,   493,   495,   502,   510,   511,   512,   532,   547,   548,
     549,   566,   568,   572,   576,   578,   580,   582,   586,   588,
     592,   593,   598,   602,   605,   613,   615,   618,   620,   623,
     625,   629,   631,   633,   636,   640,   642,   644,   646,   650,
     652,   653,   658,   668,   679,   690,   698,   707,   719,   721,
     723,   725,   727,   729,   732,   734,   738,   740,   742,   744,
     747,   750,   752,   754,   756,   758,   760,   762,   764,   767,
     770,   772,   779,   786,   793,   800,   803,   808,   812,   817,
     825,   831,   834,   839,   843,   848,   856,   862,   864,   867,
     869,   873,   879,   881,   884,   888,   890,   893,   895,   899,
     901,   903,   906,   909,   912,   915,   919,   923,   927,   931,
     935,   937,   940,   942,   944,   946,   948,   950,   952,   955,
     957,   960,   962,   966,   969,   972,   974,   977,   979,   983,
     986,   988,   991,   995,   998,  1000,  1003,  1005,  1008,  1016,
    1018,  1022,  1024,  1028,  1030,  1031,  1035,  1037,  1041,  1043,
    1047,  1050,  1051,  1057,  1062,  1065,  1068,  1071,  1073,  1075,
    1077,  1080,  1082,  1086,  1088,  1090,  1093,  1096,  1098,  1102,
    1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,  1112,
    1113,  1114,  1115,  1116,  1117,  1118,  1119,  1120,  1121,  1122,
    1123,  1124,  1125,  1126,  1127,  1128,  1129,  1130,  1131,  1132,
    1133,  1134,  1135,  1136,  1137,  1138,  1139,  1140,  1141,  1142,
    1143,  1144,  1145,  1146,  1147,  1148,  1149,  1150,  1151,  1152,
    1153,  1154,  1155,  1156,  1157,  1158,  1159,  1160,  1161,  1162,
    1163,  1164,  1165,  1166,  1167,  1168,  1169
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
      70,     0,    -1,   255,    -1,    71,    -1,    72,    -1,    71,
      72,    -1,    73,    -1,    80,    -1,    94,    -1,   101,    -1,
     117,    -1,   130,    -1,   110,    -1,   153,    -1,     1,    -1,
      -1,    41,    76,    74,    77,    35,    79,    18,    75,    58,
      -1,   256,    -1,    76,    -1,    61,    -1,   255,    -1,    51,
      78,    -1,    76,    -1,    78,    59,    76,    -1,   149,   198,
      -1,    -1,    34,    83,    81,    84,    35,    86,    18,    82,
      58,   260,    -1,   256,    -1,    61,    -1,    61,    -1,   255,
      -1,    51,    85,    -1,    76,    -1,    85,    59,    76,    -1,
     255,    -1,    87,    -1,    88,    -1,    87,    88,    -1,    41,
      76,    58,    -1,    13,   181,    58,   259,    -1,    89,    58,
      -1,   196,    90,    -1,    -1,    27,   249,   181,    91,    92,
      -1,    27,    41,    61,   211,    93,    -1,   212,    93,    -1,
     213,    93,    -1,   210,    93,    -1,   255,    -1,    48,   181,
      -1,    -1,    17,    97,    95,    35,    98,    18,    96,    58,
      -1,   256,    -1,    97,    -1,    61,    -1,   255,    -1,    99,
      -1,   100,    -1,    99,   100,    -1,    41,    76,    58,    -1,
      13,   181,    58,    -1,    -1,    19,   104,   102,   105,    35,
     107,    18,   103,    58,   261,    -1,   256,    -1,    61,    -1,
      61,    -1,   255,    -1,    27,   106,    61,    -1,   255,    -1,
      17,    -1,   255,    -1,   108,    -1,   109,    -1,   108,   109,
      -1,    34,    61,    58,    -1,    -1,    15,   113,   111,    35,
     114,    18,   112,    58,    -1,   256,    -1,    61,    -1,    61,
      -1,   255,    -1,   115,    -1,   116,    -1,   115,   116,    -1,
      34,    61,    27,    61,    58,    -1,    -1,    14,   119,   118,
     120,    35,   123,    18,   122,    58,    -1,    62,    -1,    61,
      -1,   255,    -1,    51,   121,    -1,   119,    -1,   121,    59,
     119,    -1,   255,    -1,    61,    -1,    62,    -1,   255,    -1,
     124,    -1,   125,    -1,   124,   125,    -1,    34,    61,    58,
      -1,   196,   126,    58,    -1,    -1,    27,   249,   181,   127,
     128,    -1,    27,    41,    61,   211,   129,    -1,    27,    41,
      61,   211,   129,    35,    11,    -1,   212,   129,    -1,   212,
     129,    35,    11,    -1,   213,   129,    -1,   213,   129,    35,
      11,    -1,   210,   129,    -1,   210,   129,    35,    11,    -1,
     255,    -1,    48,   181,    -1,    -1,    22,    61,    35,   131,
     132,    18,   133,    58,    -1,   255,    -1,   134,    -1,   255,
      -1,    61,    -1,   135,    -1,   134,   135,    -1,    -1,    22,
     138,   136,   139,   140,    35,   144,    18,   137,    58,    -1,
     256,    -1,   138,    -1,    61,    -1,   255,    -1,    27,   106,
      97,    -1,   255,    -1,    51,   141,    -1,   142,    -1,   141,
      59,   142,    -1,    61,    12,   143,    -1,     7,    -1,     8,
      -1,   255,    -1,   145,    -1,   146,    -1,   145,   146,    -1,
      61,   147,    58,    -1,   255,    -1,   148,    -1,     4,    -1,
       5,    -1,     3,    -1,     6,    -1,   255,    -1,   150,    -1,
     151,    -1,   150,   151,    -1,   152,    -1,    43,   315,   152,
      -1,   156,    -1,   183,    -1,   188,    -1,   184,    -1,   186,
      -1,   187,    -1,   185,    -1,   154,    -1,    43,   315,   154,
      -1,   155,    -1,    16,   316,   155,    -1,   160,    -1,   163,
      -1,   164,    -1,   157,    -1,    16,   316,   157,    -1,   158,
      -1,   159,    -1,   163,    -1,    13,   257,   181,   258,    58,
     276,    -1,    28,    13,   257,   180,   258,    58,   277,    -1,
      -1,    -1,    28,    13,   181,   278,    54,   170,    53,   174,
     161,   175,   162,   176,   177,    35,   169,    18,   179,    58,
     282,    -1,    13,   257,   181,   258,    33,   283,   181,   284,
      54,   180,    53,   285,    58,   286,    -1,    -1,    -1,    13,
     257,   181,   258,   288,   174,   165,   175,   166,   176,    35,
     169,    18,   179,    58,   289,    -1,   168,    -1,    43,   315,
     168,    -1,    45,   318,   168,    -1,   163,    -1,   164,    -1,
     158,    -1,   193,   236,   241,    -1,   171,    -1,   170,    58,
     171,    -1,    -1,    61,   172,    12,   173,    -1,    10,   322,
     279,    -1,   181,   279,    -1,   181,    54,   287,   180,    53,
     285,   280,    -1,   255,    -1,    32,   180,    -1,   255,    -1,
      51,   180,    -1,   255,    -1,    46,   180,   290,    -1,   255,
      -1,   178,    -1,   167,   281,    -1,   178,   167,   281,    -1,
     255,    -1,   181,    -1,   181,    -1,   180,    59,   181,    -1,
      61,    -1,    -1,    61,    27,   182,    76,    -1,    21,   257,
     181,   258,   272,    32,   180,    58,   273,    -1,     9,   257,
     181,   258,   262,    35,   181,   263,    58,   264,    -1,    42,
     257,   181,   258,   265,    50,   181,   266,    58,   267,    -1,
      30,   257,   181,   258,   268,    58,   269,    -1,    44,   257,
     181,   258,   270,   174,    58,   271,    -1,    20,   257,   181,
     258,   274,    35,   192,   190,    58,   189,   275,    -1,   255,
      -1,    68,    -1,   255,    -1,   191,    -1,    18,    -1,    18,
     181,    -1,    61,    -1,   192,    59,    61,    -1,   255,    -1,
     194,    -1,   195,    -1,   194,   195,    -1,   196,   197,    -1,
      61,    -1,   202,    -1,   203,    -1,   204,    -1,   255,    -1,
     199,    -1,   200,    -1,   199,   200,    -1,   196,   201,    -1,
     205,    -1,   206,   229,   230,   250,    58,   305,    -1,   208,
     228,   230,   231,    58,   305,    -1,   209,   228,   230,   250,
      58,   305,    -1,   207,   228,   230,   250,    58,   306,    -1,
     255,   294,    -1,    54,   294,   215,    53,    -1,   255,   297,
     308,    -1,    54,   297,   215,    53,    -1,    54,    37,   295,
     219,   302,   214,    53,    -1,    54,    39,   296,   214,    53,
      -1,   255,   298,    -1,    54,   298,   215,    53,    -1,   255,
     301,   308,    -1,    54,   301,   215,    53,    -1,    54,    37,
     299,   219,   302,   214,    53,    -1,    54,    39,   300,   214,
      53,    -1,   255,    -1,    58,   215,    -1,   216,    -1,   215,
      58,   216,    -1,   254,    57,   217,   222,   307,    -1,   218,
      -1,    40,   310,    -1,    31,    40,   311,    -1,   255,    -1,
      31,   309,    -1,   255,    -1,    57,   217,   220,    -1,   255,
      -1,   221,    -1,    38,   312,    -1,    10,   313,    -1,    29,
     314,    -1,   220,   225,    -1,   220,   181,   226,    -1,   220,
     181,   304,    -1,   220,   181,   304,    -1,   220,   225,   304,
      -1,    36,    37,   321,    -1,   255,    -1,    60,   227,    -1,
      63,    -1,    65,    -1,    66,    -1,    64,    -1,    61,    -1,
     255,    -1,    48,   224,    -1,   255,    -1,    48,   223,    -1,
     255,    -1,    46,   180,   303,    -1,   255,   319,    -1,    35,
     232,    -1,   253,    -1,   233,   252,    -1,   235,    -1,    47,
     317,   234,    -1,   255,   320,    -1,   235,    -1,    49,   319,
      -1,    16,   316,   320,    -1,    52,   320,    -1,   255,    -1,
      25,   237,    -1,   238,    -1,   237,   238,    -1,   254,    57,
     181,   239,   251,    58,   291,    -1,   255,    -1,    56,   240,
      55,    -1,    63,    -1,   240,    59,    63,    -1,   255,    -1,
      -1,    26,   242,   243,    -1,   244,    -1,   243,    59,   244,
      -1,   245,    -1,    13,   181,   293,    -1,   196,   246,    -1,
      -1,    27,   249,   181,   247,   248,    -1,    27,    41,    61,
     211,    -1,   212,   292,    -1,   213,   292,    -1,   210,   292,
      -1,   255,    -1,    13,    -1,   255,    -1,    35,   253,    -1,
     255,    -1,    35,    45,   318,    -1,   255,    -1,   253,    -1,
      43,   315,    -1,    45,   318,    -1,    61,    -1,   254,    59,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   121,   121,   122,   124,   125,   127,   128,   129,   130,
     131,   132,   133,   134,   137,   142,   142,   148,   149,   151,
     153,   154,   156,   157,   159,   165,   165,   172,   173,   175,
     177,   178,   180,   181,   183,   184,   186,   187,   189,   190,
     191,   194,   196,   196,   197,   200,   201,   202,   205,   206,
     210,   210,   215,   216,   218,   220,   221,   223,   224,   226,
     227,   232,   232,   239,   240,   243,   246,   247,   249,   250,
     252,   253,   255,   256,   258,   263,   263,   270,   271,   274,
     277,   278,   280,   281,   283,   289,   289,   296,   297,   300,
     301,   304,   305,   308,   309,   310,   313,   314,   317,   318,
     320,   321,   324,   324,   325,   326,   329,   330,   331,   332,
     333,   334,   337,   338,   342,   342,   346,   347,   350,   351,
     354,   355,   358,   358,   365,   366,   369,   372,   373,   376,
     377,   380,   381,   384,   387,   388,   391,   392,   395,   396,
     399,   401,   402,   405,   406,   407,   408,   414,   415,   417,
     418,   420,   421,   423,   424,   425,   426,   427,   428,   429,
     431,   432,   437,   438,   440,   441,   442,   444,   445,   447,
     448,   449,   452,   455,   460,   461,   458,   470,   478,   479,
     477,   487,   488,   489,   491,   492,   493,   496,   501,   502,
     505,   505,   508,   509,   510,   513,   514,   516,   517,   519,
     520,   522,   523,   525,   526,   528,   529,   531,   532,   534,
     535,   535,   541,   551,   561,   571,   577,   586,   594,   595,
     597,   598,   600,   601,   603,   604,   609,   610,   612,   613,
     615,   617,   619,   620,   621,   623,   624,   626,   627,   629,
     631,   634,   641,   648,   655,   663,   664,   666,   667,   669,
     672,   675,   676,   678,   679,   681,   684,   691,   692,   694,
     695,   697,   701,   702,   703,   705,   706,   708,   709,   711,
     712,   714,   715,   716,   725,   726,   728,   730,   731,   733,
     735,   736,   738,   739,   740,   741,   742,   745,   746,   748,
     749,   751,   752,   754,   755,   757,   758,   760,   761,   763,
     764,   766,   767,   768,   774,   775,   778,   779,   781,   786,
     787,   790,   791,   796,   797,   797,   799,   800,   802,   803,
     805,   807,   807,   808,   812,   813,   814,   816,   817,   823,
     824,   826,   827,   829,   830,   832,   833,   838,   839,   841,
     843,   850,   851,   853,   854,   856,   858,   859,   860,   862,
     863,   864,   866,   867,   869,   870,   872,   873,   875,   876,
     878,   879,   881,   882,   883,   884,   885,   887,   888,   889,
     890,   891,   893,   894,   896,   897,   898,   899,   901,   902,
     903,   904,   905,   906,   907,   908,   909,   910,   911,   912,
     913,   915,   917,   918,   919,   920,   921,   922,   923,   924,
     925,   926,   927,   928,   929,   930,   931
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "krc", "cpp", "fortran", "object",
  "library", "external", "alias", "any", "asynchronous", "as", "class",
  "client", "component", "deferred", "schema", "end", "engine",
  "enumeration", "exception", "executable", "execfile", "extends",
  "fields", "friends", "CDL_from", "generic", "immutable", "imported",
  "in", "inherits", "instantiates", "interface", "is", "like", "me",
  "mutable", "myclass", "out", "package", "pointer", "private",
  "primitive", "protected", "raises", "redefined", "returns", "statiC",
  "CDL_to", "uses", "virtual", "')'", "'('", "']'", "'['", "':'", "';'",
  "','", "'='", "IDENTIFIER", "JAVAIDENTIFIER", "INTEGER", "LITERAL",
  "REAL", "STRING", "INVALID", "DOCU", "$accept", "__Cdl_Declaration_List",
  "Cdl_Declaration_List", "Cdl_Declaration", "Package_Declaration", "$@1",
  "__Package_Name", "Package_Name", "__Packages_Uses", "Package_List",
  "Package_Definition", "Interface_Declaration", "$@2", "__Interface_Name",
  "Interface_Name", "__Interfaces_Uses", "InterfaceUse_List",
  "__Interface_Definitions", "Interface_Definitions",
  "Interface_Definition", "Interface_Method_Dec", "Interface_Method",
  "$@3", "Interface_Method_Class_Dec", "Interface_returns_error",
  "Schema_Declaration", "$@4", "__Schema_Name", "Schema_Name",
  "__Schema_Packages", "Schema_Packages", "Schema_Package",
  "Engine_Declaration", "$@5", "__Engine_Name", "Engine_Name",
  "__Engine_Schema", "__schema", "__Engine_Interfaces",
  "Engine_Interfaces", "Engine_Interface", "Component_Declaration", "$@6",
  "__Component_Name", "Component_Name", "__Component_Interfaces",
  "Component_Interfaces", "Component_Interface", "Client_Declaration",
  "$@7", "Client_Name", "__Client_Uses", "ClientUse_List", "__Client_End",
  "__Client_Definitions", "Client_Definitions", "Client_Definition",
  "Client_Method", "$@8", "Client_Method_Class_Dec",
  "Client_returns_error", "Executable_Declaration", "$@9",
  "__ExecFileDeclaration", "__ExecutableName", "ExecFile_DeclarationList",
  "ExecFile_Declaration", "$@10", "__ExecFile_Name", "ExecFile_Name",
  "__ExecFile_Schema", "__ExecFile_Uses", "ExecFile_List", "ExecFile_Use",
  "ExecFile_UseType", "__ExecFile_Components", "ExecFile_Components",
  "ExecFile_Component", "__ExecFile_ComponentType",
  "ExecFile_ComponentType", "__Pack_Declaration_List",
  "Pack_Declaration_List", "Pack_Declaration", "Pack_Declaration_1",
  "Separated_Declaration", "Seper_Class_Declaration",
  "Sep_Class_Declaration_1", "Pack_Class_Declaration",
  "Pac_Class_Declaration_1", "Inc_NoGeneric_Class", "Inc_Generic_Class",
  "Generic_C_Declaration", "$@11", "$@12", "Generic_C_Instanciation",
  "NoGeneric_C_Declaration", "$@13", "$@14", "Embeded_C_Declaration",
  "Embeded_C_Declaration_1", "Class_Definition", "Generic_Type_List",
  "Generic_Type", "$@15", "Type_Constraint", "__Inherits_Classes",
  "__Uses_Classes", "__Raises_Exception", "__Embeded_Class_List",
  "Embeded_Class_List", "__Class_Name", "Type_List", "Type_Name", "$@16",
  "Exception_Declaration", "Alias_Declaration", "Pointer_Declaration",
  "Imported_Declaration", "Primitive_Declaration",
  "Enumeration_Declaration", "Enumeration_Documentation",
  "__Enumeration_End", "Enumeration_End", "Enum_Item_List",
  "__Member_Method_List", "Member_Method_List", "Member_Method",
  "Method_Name", "Method_Definition", "__Extern_Method_List",
  "Extern_Method_List", "Extern_Method", "Extern_Met_Definition",
  "Constructor", "Instance_Method", "Class_Method", "Extern_Met",
  "Constructor_Header", "Extern_Method_Header", "Instance_Method_Header",
  "Class_Method_Header", "Friend_Const_Header", "Friend_ExtMet_Header",
  "Friend_InstMet_Header", "Friend_ClassMet_Header", "__S_Parameter_List",
  "Parameter_List", "Parameter", "Passage_Mode", "__In", "__Me_Mode",
  "__Acces_Mode", "Acces_Mode", "Transmeted_Type", "Constructed_Type",
  "Returned_Type", "Associated_Type", "__Initial_Value", "Initial_Value",
  "__Returnrd_Type_Dec", "__Constructed_Type_Dec", "__Errors_Declaration",
  "__Inst_Met_Attr_Dec", "Inst_Met_Attr_Dec", "Definition_Level",
  "__Redefinition", "Redefinition", "__Field_Declaration", "Field_List",
  "Field", "__Field_Dimension", "Integer_List", "__Friends_Declaration",
  "$@17", "Friend_List", "Friend", "Friend_Method_Dec", "Friend_Method",
  "$@18", "Friend_Method_Type_Dec", "__Class", "__Scoop_Declaration",
  "__Scoop_Pro_Declaration", "__Scoop", "Scoop", "Name_List", "Empty",
  "Empty_Str", "dollardset_inc_state", "dollardrestore_state",
  "dollardInterface_Class", "dollardInterface_End", "dollardEngine_End",
  "dollardAlias_Begin", "dollardAlias_Type", "dollardAlias_End",
  "dollardPointer_Begin", "dollardPointer_Type", "dollardPointer_End",
  "dollardImported_Begin", "dollardImported_End", "dollardPrim_Begin",
  "dollardPrim_End", "dollardExcept_Begin", "dollardExcept_End",
  "dollardEnum_Begin", "dollardEnum_End", "dollardInc_Class_Dec",
  "dollardInc_GenClass_Dec", "dollardGenClass_Begin", "dollardAdd_GenType",
  "dollardAdd_DynaGenType", "dollardAdd_Embeded", "dollardGenClass_End",
  "dollardInstClass_Begin", "dollardAdd_Gen_Class", "dollardAdd_InstType",
  "dollardInstClass_End", "dollardDynaType_Begin", "dollardStdClass_Begin",
  "dollardStdClass_End", "dollardAdd_Raises", "dollardAdd_Field",
  "dollardAdd_FriendMet", "dollardAdd_Friend_Class",
  "dollardConstruct_Begin", "dollardInstMet_Begin",
  "dollardClassMet_Begin", "dollardExtMet_Begin",
  "dollardFriend_Construct_Begin", "dollardFriend_InstMet_Begin",
  "dollardFriend_ClassMet_Begin", "dollardFriend_ExtMet_Begin",
  "dollardAdd_Me", "dollardAdd_MetRaises", "dollardAdd_Returns",
  "dollardMemberMet_End", "dollardExternMet_End", "dollardParam_Begin",
  "dollardEnd", "dollardSet_In", "dollardSet_Out", "dollardSet_InOut",
  "dollardSet_Mutable", "dollardSet_Mutable_Any", "dollardSet_Immutable",
  "dollardSet_Priv", "dollardSet_Defe", "dollardSet_Redefined",
  "dollardSet_Prot", "dollardSet_Static", "dollardSet_Virtual",
  "dollardSet_Like_Me", "dollardSet_Any", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,    41,    40,    93,    91,    58,    59,    44,
      61,   308,   309,   310,   311,   312,   313,   314,   315
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint16 yyr1[] =
{
       0,    69,    70,    70,    71,    71,    72,    72,    72,    72,
      72,    72,    72,    72,    72,    74,    73,    75,    75,    76,
      77,    77,    78,    78,    79,    81,    80,    82,    82,    83,
      84,    84,    85,    85,    86,    86,    87,    87,    88,    88,
      88,    89,    91,    90,    90,    92,    92,    92,    93,    93,
      95,    94,    96,    96,    97,    98,    98,    99,    99,   100,
     100,   102,   101,   103,   103,   104,   105,   105,   106,   106,
     107,   107,   108,   108,   109,   111,   110,   112,   112,   113,
     114,   114,   115,   115,   116,   118,   117,   119,   119,   120,
     120,   121,   121,   122,   122,   122,   123,   123,   124,   124,
     125,   125,   127,   126,   126,   126,   128,   128,   128,   128,
     128,   128,   129,   129,   131,   130,   132,   132,   133,   133,
     134,   134,   136,   135,   137,   137,   138,   139,   139,   140,
     140,   141,   141,   142,   143,   143,   144,   144,   145,   145,
     146,   147,   147,   148,   148,   148,   148,   149,   149,   150,
     150,   151,   151,   152,   152,   152,   152,   152,   152,   152,
     153,   153,   154,   154,   155,   155,   155,   156,   156,   157,
     157,   157,   158,   159,   161,   162,   160,   163,   165,   166,
     164,   167,   167,   167,   168,   168,   168,   169,   170,   170,
     172,   171,   173,   173,   173,   174,   174,   175,   175,   176,
     176,   177,   177,   178,   178,   179,   179,   180,   180,   181,
     182,   181,   183,   184,   185,   186,   187,   188,   189,   189,
     190,   190,   191,   191,   192,   192,   193,   193,   194,   194,
     195,   196,   197,   197,   197,   198,   198,   199,   199,   200,
     201,   202,   203,   204,   205,   206,   206,   207,   207,   208,
     209,   210,   210,   211,   211,   212,   213,   214,   214,   215,
     215,   216,   217,   217,   217,   218,   218,   219,   219,   220,
     220,   221,   221,   221,   222,   222,   223,   224,   224,   225,
     226,   226,   227,   227,   227,   227,   227,   228,   228,   229,
     229,   230,   230,   231,   231,   232,   232,   233,   233,   234,
     234,   235,   235,   235,   236,   236,   237,   237,   238,   239,
     239,   240,   240,   241,   242,   241,   243,   243,   244,   244,
     245,   247,   246,   246,   248,   248,   248,   249,   249,   250,
     250,   251,   251,   252,   252,   253,   253,   254,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,   278,   279,   280,   281,   282,   283,   284,   285,
     286,   287,   288,   289,   290,   291,   292,   293,   294,   295,
     296,   297,   298,   299,   300,   301,   302,   303,   304,   305,
     306,   307,   308,   309,   310,   311,   312,   313,   314,   315,
     316,   317,   318,   319,   320,   321,   322
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     2,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     0,     9,     1,     1,     1,
       1,     2,     1,     3,     2,     0,    10,     1,     1,     1,
       1,     2,     1,     3,     1,     1,     1,     2,     3,     4,
       2,     2,     0,     5,     5,     2,     2,     2,     1,     2,
       0,     8,     1,     1,     1,     1,     1,     1,     2,     3,
       3,     0,    10,     1,     1,     1,     1,     3,     1,     1,
       1,     1,     1,     2,     3,     0,     8,     1,     1,     1,
       1,     1,     1,     2,     5,     0,     9,     1,     1,     1,
       2,     1,     3,     1,     1,     1,     1,     1,     1,     2,
       3,     3,     0,     5,     5,     7,     2,     4,     2,     4,
       2,     4,     1,     2,     0,     8,     1,     1,     1,     1,
       1,     2,     0,    10,     1,     1,     1,     1,     3,     1,
       2,     1,     3,     3,     1,     1,     1,     1,     1,     2,
       3,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       2,     1,     3,     1,     1,     1,     1,     1,     1,     1,
       1,     3,     1,     3,     1,     1,     1,     1,     3,     1,
       1,     1,     6,     7,     0,     0,    19,    14,     0,     0,
      16,     1,     3,     3,     1,     1,     1,     3,     1,     3,
       0,     4,     3,     2,     7,     1,     2,     1,     2,     1,
       3,     1,     1,     2,     3,     1,     1,     1,     3,     1,
       0,     4,     9,    10,    10,     7,     8,    11,     1,     1,
       1,     1,     1,     2,     1,     3,     1,     1,     1,     2,
       2,     1,     1,     1,     1,     1,     1,     1,     2,     2,
       1,     6,     6,     6,     6,     2,     4,     3,     4,     7,
       5,     2,     4,     3,     4,     7,     5,     1,     2,     1,
       3,     5,     1,     2,     3,     1,     2,     1,     3,     1,
       1,     2,     2,     2,     2,     3,     3,     3,     3,     3,
       1,     2,     1,     1,     1,     1,     1,     1,     2,     1,
       2,     1,     3,     2,     2,     1,     2,     1,     3,     2,
       1,     2,     3,     2,     1,     2,     1,     2,     7,     1,
       3,     1,     3,     1,     0,     3,     1,     3,     1,     3,
       2,     0,     5,     4,     2,     2,     2,     1,     1,     1,
       2,     1,     3,     1,     1,     2,     2,     1,     3,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
       0,    14,   341,     0,     0,   400,     0,     0,     0,     0,
       0,     0,   399,     0,     0,     4,     6,     7,     8,     9,
      12,    10,    11,    13,   160,   162,   164,   165,   166,     2,
       0,    88,    87,    85,    79,    75,     0,    54,    50,    65,
      61,     0,     0,    29,    25,    19,    15,     0,     1,     5,
     209,   342,   339,     0,   163,     0,   339,   114,   362,   339,
     339,   161,   210,   372,     0,     0,    89,   339,   339,   339,
       0,    66,   339,     0,     0,     0,    30,     0,     0,    20,
       0,   367,   339,    91,    90,   339,     0,     0,    81,    82,
      80,     0,     0,     0,    56,    57,    55,    69,     0,    68,
     339,     0,     0,   117,   120,   116,     0,    32,    31,   339,
      22,    21,   339,   211,     0,     0,   178,   195,     0,     0,
     231,     0,    97,    98,     0,    96,     0,   340,    83,     0,
       0,   340,    58,    67,     0,     0,    71,    72,    70,   126,
     122,   339,   121,   190,     0,   188,     0,     0,     0,     0,
      35,    36,     0,     0,    34,     0,   341,   341,   400,   341,
     341,     0,   341,   341,   399,   341,     0,   339,   148,   149,
     151,   153,   167,   169,   170,   171,   154,   156,   159,   157,
     158,   155,   147,   368,   196,   207,   339,    92,     0,   339,
      99,   339,     0,     0,    78,     0,    77,    60,    59,     0,
      53,    52,     0,   340,    73,   339,   119,     0,   118,     0,
     339,     0,    33,     0,     0,   340,    37,    40,   339,    41,
      23,     0,     0,     0,     0,     0,   341,     0,     0,     0,
       0,   340,   339,    24,   236,   237,   235,   150,     0,     0,
       0,   179,   197,   100,    94,    95,     0,    93,   328,     0,
       0,   327,   101,     0,    76,    51,    74,    64,     0,    63,
     339,   339,   127,   115,     0,   174,   189,   343,    38,    28,
       0,    27,     0,     0,   342,   342,   168,   342,   342,     0,
     342,   342,   152,   342,     0,    18,    17,   381,   239,   240,
     339,   381,   238,     0,   208,   198,   339,    86,   339,   102,
      84,   345,     0,     0,     0,   129,   406,   191,   363,   339,
      39,   344,   339,    42,   346,     0,   358,   356,   342,   352,
     349,   354,    16,     0,   339,   339,   287,   392,     0,     0,
       0,   199,   385,   339,   385,   339,    62,   128,     0,   130,
     131,   339,   363,   371,   193,   175,    26,   339,   339,     0,
     360,     0,     0,     0,     0,     0,   339,   337,     0,   259,
       0,   397,   398,   396,     0,   270,   288,   269,     0,   339,
     291,   247,   369,   374,   339,     0,     0,   104,   112,   392,
     382,   103,   339,   339,   339,   382,     0,     0,   339,     0,
     137,   138,   136,   192,     0,   339,     0,    44,    48,    43,
     339,   339,   339,     0,   172,     0,     0,   361,   353,     0,
       0,   248,     0,   339,     0,   272,   273,   271,     0,   388,
     388,   387,     0,     0,   329,     0,   200,     0,   339,   227,
     228,   339,   226,     0,   113,     0,   253,   383,   384,     0,
     110,   106,   108,   251,   134,   135,   133,   132,   145,   143,
     144,   146,     0,   142,   141,   340,   139,     0,   339,    49,
      47,    45,    46,   347,   224,   339,     0,   173,   215,   350,
     355,   260,   393,   394,   339,   262,   265,   338,   405,   277,
     278,   292,   399,   402,   330,   390,   370,   339,     0,   339,
     304,   229,   378,   230,   232,   233,   234,   339,   339,   339,
     378,   254,   105,   339,   339,     0,     0,     0,     0,   140,
       0,   125,   124,   369,   341,   399,   402,   186,   184,   185,
     365,   181,     0,   202,   201,     0,   222,     0,     0,   221,
     220,   357,     0,   216,   395,   266,   263,     0,   391,   279,
     335,   336,   244,   177,     0,   206,   205,   305,   306,     0,
     314,   187,   313,   379,   380,     0,   339,   339,   289,   339,
     339,   245,   339,   386,   267,     0,     0,   257,   252,   111,
     107,   109,   123,   364,     0,     0,     0,   203,   339,   365,
     348,   223,   225,   339,   212,   351,   264,   339,   274,   261,
     373,   307,     0,     0,   339,   339,     0,     0,   290,   339,
     339,   339,   339,   339,   258,   256,   194,   342,   182,   183,
       0,   204,   213,   219,   359,   218,   214,     0,   275,   280,
     180,   339,     0,     0,   315,   316,   318,   386,     0,   246,
     388,     0,     0,     0,   403,     0,   268,     0,   372,   339,
     217,   286,   282,   285,   283,   284,   281,     0,   339,   309,
     377,   339,   320,     0,   339,   250,   276,   389,   400,   401,
     403,   404,   294,   339,   297,   295,   389,   293,   389,   255,
       0,   311,     0,     0,     0,   331,   319,     0,     0,   317,
       0,   241,   404,   339,   301,   303,   296,   334,   333,   242,
     243,   366,   310,     0,   402,   375,   339,   321,   249,   302,
     298,   300,   404,   176,   312,   332,   308,   323,   339,   299,
     376,   376,   376,   322,   326,   324,   325
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    13,    14,    15,    16,    60,   284,    46,    78,   111,
     166,    17,    59,   270,    44,    75,   108,   149,   150,   151,
     152,   219,   348,   399,   397,    18,    55,   199,    38,    93,
      94,    95,    19,    56,   258,    40,    70,    98,   135,   136,
     137,    20,    53,   195,    35,    87,    88,    89,    21,    52,
      33,    65,    84,   246,   121,   122,   123,   192,   335,   381,
     377,    22,    72,   102,   207,   103,   104,   205,   510,   140,
     261,   304,   339,   340,   446,   389,   390,   391,   452,   453,
     167,   168,   169,   170,    23,    24,    25,   171,   172,   173,
     174,    26,   309,   395,    27,    28,   186,   296,   520,   521,
     427,   144,   145,   209,   307,   116,   241,   330,   522,   523,
     544,   184,   185,    80,   176,   177,   178,   179,   180,   181,
     614,   528,   529,   465,   428,   429,   430,   431,   493,   233,
     234,   235,   288,   494,   495,   496,   289,   497,   290,   498,
     499,   382,   333,   383,   384,   566,   358,   359,   474,   475,
     563,   364,   365,   538,   598,   366,   420,   618,   646,   325,
     557,   369,   633,   662,   663,   700,   664,   489,   547,   548,
     648,   672,   551,   593,   624,   625,   626,   652,   708,   713,
     250,   423,   674,   686,   484,   360,   367,   196,    30,    63,
     310,   346,   336,   349,   525,   612,   355,   532,   616,   354,
     468,   356,   533,   352,   584,   351,   640,   404,   467,    73,
     344,   606,   577,   703,   114,   238,   425,   543,   394,    82,
     620,   426,   706,   714,   676,   555,   594,   595,   323,   439,
     503,   504,   375,   603,   481,   479,   681,   542,   589,   371,
     535,   536,   586,   417,   415,   416,    47,    36,   683,   541,
     667,   685,   539,   342
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -586
static const yytype_int16 yypact[] =
{
     254,  -586,  -586,   126,    -4,  -586,     4,    63,    81,   136,
      97,   102,  -586,   184,   392,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
     134,  -586,  -586,  -586,  -586,  -586,   115,  -586,  -586,  -586,
    -586,   168,   134,  -586,  -586,  -586,  -586,   105,  -586,  -586,
     190,  -586,   176,   189,  -586,   195,   212,  -586,  -586,   183,
     198,  -586,  -586,   230,   126,   231,  -586,   238,    38,   258,
     246,  -586,   261,   235,   102,   256,  -586,   102,   257,  -586,
     102,  -586,   262,  -586,   234,    19,   239,   281,   238,  -586,
    -586,   134,   102,   283,    38,  -586,  -586,  -586,   241,  -586,
     269,   243,   287,   261,  -586,  -586,   245,  -586,   248,    33,
    -586,   249,   155,  -586,   134,   134,  -586,  -586,   126,   250,
    -586,   292,    19,  -586,   286,  -586,   288,   253,  -586,   259,
     260,     4,  -586,  -586,   255,   301,   269,  -586,  -586,  -586,
    -586,   263,  -586,  -586,   104,  -586,   102,   134,   102,   302,
      33,  -586,   264,   294,  -586,   102,  -586,  -586,  -586,  -586,
    -586,   310,  -586,  -586,  -586,  -586,   308,   267,   155,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,   270,  -586,   279,  -586,   273,   216,
    -586,    45,   274,   275,  -586,   276,  -586,  -586,  -586,   280,
    -586,  -586,   282,   278,  -586,   315,  -586,   291,  -586,   325,
     262,   245,  -586,   295,   296,   284,  -586,  -586,    60,  -586,
    -586,   134,   134,   119,   134,   134,  -586,   134,   134,   191,
     134,   102,   290,  -586,   267,  -586,  -586,  -586,   298,   134,
     134,  -586,  -586,  -586,  -586,  -586,   297,  -586,  -586,   285,
     134,  -586,  -586,   299,  -586,  -586,  -586,  -586,   300,  -586,
     258,   311,  -586,  -586,    34,  -586,  -586,  -586,  -586,  -586,
     303,  -586,   289,   134,  -586,  -586,  -586,  -586,  -586,   134,
    -586,  -586,  -586,  -586,   305,  -586,  -586,  -586,  -586,  -586,
     318,  -586,  -586,   134,  -586,   270,   324,  -586,   317,  -586,
    -586,  -586,     4,   312,   340,  -586,  -586,  -586,   322,   279,
    -586,  -586,   317,  -586,  -586,    17,  -586,  -586,   270,  -586,
    -586,  -586,  -586,   319,    52,   332,  -586,  -586,    61,   134,
     344,  -586,  -586,   333,  -586,   331,  -586,  -586,   374,   328,
    -586,   330,  -586,  -586,  -586,  -586,  -586,   341,   331,   359,
    -586,   361,   366,   345,   354,   349,   262,  -586,   107,  -586,
     113,  -586,  -586,  -586,    75,  -586,  -586,  -586,   134,   380,
    -586,  -586,  -586,   270,   267,   319,   134,   382,  -586,  -586,
     207,  -586,   333,   333,   333,  -586,   173,   312,   210,   400,
     330,  -586,  -586,  -586,   134,   324,   134,  -586,  -586,  -586,
     341,   341,   341,   134,  -586,   358,   134,  -586,  -586,   134,
     363,  -586,   319,    24,   362,  -586,  -586,  -586,   385,  -586,
    -586,   270,   202,   367,  -586,   369,  -586,   406,   404,   267,
    -586,   376,  -586,   108,  -586,   421,  -586,  -586,  -586,   319,
     399,   402,   403,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,   381,  -586,  -586,   243,  -586,    85,    92,  -586,
    -586,  -586,  -586,  -586,  -586,    30,   194,  -586,  -586,  -586,
    -586,  -586,   401,  -586,    52,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,   134,   319,   414,
    -586,  -586,   211,  -586,  -586,  -586,  -586,   394,   318,   318,
    -586,  -586,  -586,   386,   387,   121,   433,   435,   436,  -586,
     390,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,   415,    92,  -586,   391,   134,   393,   395,  -586,
    -586,  -586,   397,  -586,  -586,  -586,  -586,    75,  -586,  -586,
    -586,  -586,  -586,  -586,   398,  -586,  -586,   319,  -586,   199,
    -586,  -586,  -586,  -586,  -586,   319,    52,   332,  -586,   332,
     332,  -586,    24,  -586,  -586,   319,   407,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,   134,   438,   438,  -586,   267,  -586,
    -586,  -586,  -586,   384,  -586,  -586,  -586,   410,  -586,  -586,
    -586,  -586,   134,    36,   386,   387,   143,   134,  -586,   380,
     422,   380,    52,   387,   405,  -586,  -586,  -586,  -586,  -586,
     441,  -586,  -586,  -586,  -586,  -586,  -586,    90,  -586,  -586,
    -586,   408,   134,   434,   412,  -586,  -586,  -586,   409,  -586,
    -586,   416,    82,   417,  -586,   418,  -586,   413,    17,   134,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,   419,   432,  -586,
    -586,    89,  -586,    36,   387,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,   202,  -586,  -586,  -586,  -586,  -586,  -586,
     420,  -586,   118,   427,   423,  -586,  -586,   424,   134,  -586,
     426,  -586,  -586,    55,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,   428,  -586,  -586,   317,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,   331,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -586,  -586,  -586,   459,  -586,  -586,  -586,   -38,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,   327,
    -586,  -586,  -586,  -586,  -164,  -586,  -586,  -586,  -120,  -586,
    -586,   389,  -586,  -586,  -586,  -586,  -586,   220,  -586,  -586,
     348,  -586,  -586,  -586,  -586,  -586,  -586,   425,  -586,  -586,
     -30,  -586,  -586,  -586,  -586,  -586,   364,  -586,  -586,  -586,
    -141,  -586,  -586,  -586,  -586,  -586,   411,  -586,  -586,    35,
    -586,  -586,  -586,   106,  -586,  -586,  -586,   110,  -586,  -586,
    -586,  -586,   326,   266,  -586,   445,   460,  -586,   293,  -436,
    -586,  -586,  -586,  -586,  -107,  -430,  -586,  -586,   -22,  -296,
     -73,  -586,   304,  -586,  -586,  -197,   197,   112,  -586,  -586,
    -131,  -216,     1,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,    83,   -84,  -586,  -586,
    -586,   277,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -344,  -306,  -341,  -340,  -558,  -363,    98,   -45,  -586,
     -76,  -433,  -586,  -586,  -586,  -586,   -18,  -586,  -586,  -214,
    -586,  -351,  -586,  -586,  -586,  -586,  -163,  -586,  -586,   -26,
    -586,  -586,  -586,  -586,  -586,  -130,  -586,  -586,  -586,  -586,
    -215,  -342,  -586,  -586,  -585,  -448,     0,  -112,  -142,  -248,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
    -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,  -586,
     180,  -586,   -55,  -586,  -586,  -586,    12,  -586,  -586,  -586,
    -586,  -586,  -586,  -425,  -586,    26,  -586,  -586,   237,   144,
    -586,  -586,   196,   -96,  -586,  -410,  -404,  -586,  -586,   153,
    -586,  -586,  -586,  -586,  -586,  -586,  -155,  -156,  -586,  -500,
    -127,  -576,  -586,  -586
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -340
static const yytype_int16 yytable[] =
{
      29,   124,   223,   273,   400,   175,   347,   401,   402,   229,
     480,   200,   433,   265,   221,   222,   576,   224,   225,   201,
     227,   228,   517,   230,   295,   153,   314,   315,   519,   316,
     317,    51,   319,   320,    83,   321,   107,   628,   124,   110,
     549,   537,   113,    58,   306,   637,   147,   665,   526,   622,
      81,    91,    66,   119,   130,   472,    71,    34,   248,    76,
      79,   175,   361,   318,   473,    37,   153,    90,    96,    99,
     353,   658,   105,   248,   148,   350,   505,   328,   687,    92,
     120,   362,   117,   232,   279,   125,   249,   517,   187,   527,
     363,   259,   129,   519,   120,    50,   680,   120,   658,   549,
     138,   272,   248,   271,   660,   514,   699,   661,   212,   154,
     214,   418,   182,   373,   372,   183,   175,   220,     2,   286,
     239,     5,   175,   597,    39,   482,   709,   483,     2,   659,
     677,   660,   157,     9,   661,   515,    50,   516,   513,   517,
     517,   208,    41,     9,   239,   519,   519,   161,   213,    42,
     232,   641,   421,   642,   643,   644,   645,   210,    43,   410,
     411,   501,   211,    45,   156,   412,   412,   236,   157,   636,
     413,   158,   414,   692,   568,   159,   160,   693,   457,   412,
     444,   445,   337,   161,    48,   162,   242,    31,    32,   247,
     466,   251,   596,   285,   705,    50,   629,   163,   164,   165,
     156,   412,   604,    57,   157,   262,   599,   158,   600,   601,
     117,   159,   160,   448,   449,   450,   451,    62,   251,   161,
     656,   162,   274,   275,    67,   277,   278,    64,   280,   281,
      68,   283,   291,   163,    74,   165,   460,   461,   462,    69,
     294,   440,   441,   442,   437,   482,   438,   483,   553,    77,
     554,   299,   531,   239,  -339,     1,   592,   631,   414,   635,
      99,   305,   689,    81,   690,   308,    85,     2,     3,     4,
       5,     6,    86,     7,   313,    97,     8,   244,   245,   608,
     609,   100,     9,   101,   559,   560,   715,   716,    10,   106,
     326,   109,   112,   118,   115,    11,   331,    12,   334,   127,
     126,   131,   133,   134,   139,   141,   143,   146,   155,   242,
     189,   188,   334,   191,   194,   193,   202,   197,   198,   203,
     215,   218,   217,   226,   206,   370,   231,   540,   120,   239,
     240,   243,   252,   378,   254,   385,   253,   264,   255,   257,
     256,   392,   260,   512,   287,   269,   298,   398,   385,   263,
     312,   518,   293,   267,   268,   297,   117,   300,   301,   638,
     575,   311,   303,   322,   710,   419,   324,   711,   712,   424,
     329,   332,   574,   338,   432,   341,   343,   434,   368,   374,
     357,   376,   378,   378,   378,   380,   386,   387,   454,   396,
     707,   388,    -3,     1,   403,   331,   405,   459,   406,   409,
     398,   398,   398,   407,   463,     2,     3,     4,     5,     6,
     469,     7,   408,   476,     8,   422,   518,   435,   455,   464,
       9,   470,   478,   477,   487,   485,    10,   486,   490,   488,
     492,   500,   502,    11,   506,    12,   678,   507,   508,   509,
     550,   534,   556,   562,   569,   565,   570,   571,   572,   580,
     578,   514,   613,   583,   582,   585,   590,   632,   524,   639,
     605,   651,   655,   412,   647,   530,   669,   673,   518,   518,
     617,   653,   694,    49,   657,   666,   668,   216,   691,   698,
     302,   695,   671,   132,   204,   696,   190,   546,   545,   552,
     511,   704,    61,   447,   237,   282,    54,   558,   326,   326,
     456,   579,   682,   564,   567,   610,   345,   458,   670,   623,
     471,   292,   491,   128,   142,   266,   276,   602,   627,   588,
     701,   591,   393,   679,   611,   573,   561,   581,   327,   443,
     379,   654,   436,   684,     0,     0,     0,     0,   587,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   370,     0,   370,
     370,     0,   476,     0,     0,     0,     0,     0,     0,   623,
       0,     0,     0,     0,     0,   607,     0,     0,   432,     0,
       0,     0,     0,   615,     0,     0,     0,   619,     0,     0,
       0,     0,     0,   621,   564,   567,     0,     0,   630,   424,
     634,   424,     0,   567,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   649,     0,   650,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   546,
     545,     0,     0,     0,     0,     0,     0,     0,   675,     0,
       0,   251,     0,     0,   567,     0,     0,     0,     0,     0,
       0,     0,     0,   688,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   697,
       0,     0,     0,   702,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   334,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   385
};

static const yytype_int16 yycheck[] =
{
       0,    85,   158,   218,   348,   112,   312,   348,   348,   164,
     420,   131,   375,   210,   156,   157,   516,   159,   160,   131,
     162,   163,   458,   165,   240,   109,   274,   275,   458,   277,
     278,    30,   280,   281,    64,   283,    74,   595,   122,    77,
     488,   474,    80,    42,    10,   603,    13,   632,    18,    13,
      33,    13,    52,    34,    92,    31,    56,    61,    13,    59,
      60,   168,    10,   279,    40,    61,   150,    67,    68,    69,
     318,    16,    72,    13,    41,    58,   439,   293,   663,    41,
      61,    29,    82,   167,   226,    85,    41,   523,   118,    59,
      38,   203,    91,   523,    61,    61,   654,    61,    16,   547,
     100,    41,    13,   215,    49,    13,   682,    52,   146,   109,
     148,    36,   112,   329,    53,   114,   223,   155,    13,   231,
      59,    16,   229,   556,    61,    43,   702,    45,    13,    47,
      41,    49,    13,    28,    52,    43,    61,    45,    53,   575,
     576,   141,    61,    28,    59,   575,   576,    28,   147,    13,
     234,    61,   368,    63,    64,    65,    66,    53,    61,   356,
      53,    53,    58,    61,     9,    58,    58,   167,    13,   602,
      57,    16,    59,    55,    53,    20,    21,    59,   394,    58,
       7,     8,   302,    28,     0,    30,   186,    61,    62,   189,
     406,   191,   555,   231,   694,    61,    53,    42,    43,    44,
       9,    58,   565,    35,    13,   205,   557,    16,   559,   560,
     210,    20,    21,     3,     4,     5,     6,    27,   218,    28,
     630,    30,   221,   222,    35,   224,   225,    51,   227,   228,
      35,   230,   232,    42,    51,    44,   400,   401,   402,    27,
     239,   382,   383,   384,    37,    43,    39,    45,    37,    51,
      39,   250,    58,    59,     0,     1,    57,   599,    59,   601,
     260,   261,   666,    33,   668,   264,    35,    13,    14,    15,
      16,    17,    34,    19,   273,    17,    22,    61,    62,   575,
     576,    35,    28,    22,   498,   499,   711,   712,    34,    54,
     290,    35,    35,    59,    32,    41,   296,    43,   298,    18,
      61,    18,    61,    34,    61,    18,    61,    59,    59,   309,
      18,    61,   312,    27,    61,    27,    61,    58,    58,    18,
      18,    27,    58,    13,    61,   325,    18,   482,    61,    59,
      51,    58,    58,   333,    58,   335,    61,    12,    58,    61,
      58,   341,    27,   455,    54,    61,    61,   347,   348,    58,
      61,   458,    54,    58,    58,    58,   356,    58,    58,   607,
     515,    58,    51,    58,   708,   364,    48,   708,   708,   369,
      46,    54,   514,    61,   374,    35,    54,   376,    46,    35,
      61,    48,   382,   383,   384,    54,    12,    59,   388,    48,
     696,    61,     0,     1,    35,   395,    35,   396,    32,    50,
     400,   401,   402,    58,   403,    13,    14,    15,    16,    17,
     409,    19,    58,   413,    22,    35,   523,    35,    18,    61,
      28,    58,    37,    61,    18,    58,    34,    58,   428,    25,
      54,   431,    11,    41,    35,    43,   651,    35,    35,    58,
      26,    40,    48,    57,    11,    58,    11,    11,    58,    58,
      35,    13,    68,    58,    61,    58,    58,    35,   458,    18,
      53,    27,    53,    58,    56,   465,    53,    35,   575,   576,
      60,    59,    45,    14,    58,    58,    58,   150,    58,    53,
     260,    58,    63,    94,   136,    61,   122,   487,   487,   489,
     455,    63,    47,   387,   168,   229,    36,   497,   498,   499,
     390,   523,   658,   503,   504,   578,   309,   395,   639,   593,
     412,   234,   429,    88,   103,   211,   223,   562,   594,   537,
     683,   547,   342,   653,   579,   513,   500,   526,   291,   385,
     334,   627,   379,   660,    -1,    -1,    -1,    -1,   537,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   557,    -1,   559,
     560,    -1,   562,    -1,    -1,    -1,    -1,    -1,    -1,   653,
      -1,    -1,    -1,    -1,    -1,   574,    -1,    -1,   578,    -1,
      -1,    -1,    -1,   583,    -1,    -1,    -1,   587,    -1,    -1,
      -1,    -1,    -1,   592,   594,   595,    -1,    -1,   597,   599,
     600,   601,    -1,   603,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   621,    -1,   622,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   639,
     639,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   648,    -1,
      -1,   651,    -1,    -1,   654,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   663,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   678,
      -1,    -1,    -1,   683,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   696,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   708
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint16 yystos[] =
{
       0,     1,    13,    14,    15,    16,    17,    19,    22,    28,
      34,    41,    43,    70,    71,    72,    73,    80,    94,   101,
     110,   117,   130,   153,   154,   155,   160,   163,   164,   255,
     257,    61,    62,   119,    61,   113,   316,    61,    97,    61,
     104,    61,    13,    61,    83,    61,    76,   315,     0,    72,
      61,   181,   118,   111,   155,    95,   102,    35,   181,    81,
      74,   154,    27,   258,    51,   120,   255,    35,    35,    27,
     105,   255,   131,   278,    51,    84,   255,    51,    77,   255,
     182,    33,   288,   119,   121,    35,    34,   114,   115,   116,
     255,    13,    41,    98,    99,   100,   255,    17,   106,   255,
      35,    22,   132,   134,   135,   255,    54,    76,    85,    35,
      76,    78,    35,    76,   283,    32,   174,   255,    59,    34,
      61,   123,   124,   125,   196,   255,    61,    18,   116,   181,
      76,    18,   100,    61,    34,   107,   108,   109,   255,    61,
     138,    18,   135,    61,   170,   171,    59,    13,    41,    86,
      87,    88,    89,   196,   255,    59,     9,    13,    16,    20,
      21,    28,    30,    42,    43,    44,    79,   149,   150,   151,
     152,   156,   157,   158,   159,   163,   183,   184,   185,   186,
     187,   188,   255,   181,   180,   181,   165,   119,    61,    18,
     125,    27,   126,    27,    61,   112,   256,    58,    58,    96,
      97,   256,    61,    18,   109,   136,    61,   133,   255,   172,
      53,    58,    76,   181,    76,    18,    88,    58,    27,    90,
      76,   257,   257,   316,   257,   257,    13,   257,   257,   315,
     257,    18,   196,   198,   199,   200,   255,   151,   284,    59,
      51,   175,   255,    58,    61,    62,   122,   255,    13,    41,
     249,   255,    58,    61,    58,    58,    58,    61,   103,   256,
      27,   139,   255,    58,    12,   174,   171,    58,    58,    61,
      82,   256,    41,   249,   181,   181,   157,   181,   181,   257,
     181,   181,   152,   181,    75,    76,   256,    54,   201,   205,
     207,   255,   200,    54,   181,   180,   166,    58,    61,   181,
      58,    58,   106,    51,   140,   255,    10,   173,   181,   161,
     259,    58,    61,   181,   258,   258,   258,   258,   180,   258,
     258,   258,    58,   297,    48,   228,   255,   297,   180,    46,
     176,   255,    54,   211,   255,   127,   261,    97,    61,   141,
     142,    35,   322,    54,   279,   175,   260,   211,    91,   262,
      58,   274,   272,   258,   268,   265,   270,    61,   215,   216,
     254,    10,    29,    38,   220,   221,   224,   255,    46,   230,
     255,   308,    53,   180,    35,   301,    48,   129,   255,   301,
      54,   128,   210,   212,   213,   255,    12,    59,    61,   144,
     145,   146,   255,   279,   287,   162,    48,    93,   255,    92,
     210,   212,   213,    35,   276,    35,    32,    58,    58,    50,
     174,    53,    58,    57,    59,   313,   314,   312,    36,   181,
     225,   180,    35,   250,   255,   285,   290,   169,   193,   194,
     195,   196,   255,   215,   181,    35,   308,    37,    39,   298,
     129,   129,   129,   298,     7,     8,   143,   142,     3,     4,
       5,     6,   147,   148,   255,    18,   146,   180,   176,   181,
      93,    93,    93,   181,    61,   192,   180,   277,   269,   181,
      58,   216,    31,    40,   217,   218,   255,    61,    37,   304,
     304,   303,    43,    45,   253,    58,    58,    18,    25,   236,
     255,   195,    54,   197,   202,   203,   204,   206,   208,   209,
     255,    53,    11,   299,   300,   215,    35,    35,    35,    58,
     137,   138,   256,    53,    13,    43,    45,   158,   163,   164,
     167,   168,   177,   178,   255,   263,    18,    59,   190,   191,
     255,    58,   266,   271,    40,   309,   310,   220,   222,   321,
     315,   318,   306,   286,   179,   181,   255,   237,   238,   254,
      26,   241,   255,    37,    39,   294,    48,   229,   255,   228,
     228,   294,    57,   219,   255,    58,   214,   255,    53,    11,
      11,    11,    58,   285,   257,   315,   318,   281,    35,   167,
      58,   181,    61,    58,   273,    58,   311,   181,   225,   307,
      58,   238,    57,   242,   295,   296,   215,   220,   223,   230,
     230,   230,   217,   302,   215,    53,   280,   181,   168,   168,
     169,   281,   264,    68,   189,   255,   267,    60,   226,   255,
     289,   181,    13,   196,   243,   244,   245,   219,   214,    53,
     181,   250,    35,   231,   255,   250,   220,   214,   258,    18,
     275,    61,    63,    64,    65,    66,   227,    56,   239,   255,
     181,    27,   246,    59,   302,    53,   304,    58,    16,    47,
      49,    52,   232,   233,   235,   253,    58,   319,    58,    53,
     179,    63,   240,    35,   251,   255,   293,    41,   249,   244,
     214,   305,   316,   317,   319,   320,   252,   253,   255,   305,
     305,    58,    55,    59,    45,    58,    61,   181,    53,   320,
     234,   235,   255,   282,    63,   318,   291,   211,   247,   320,
     210,   212,   213,   248,   292,   292,   292
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
#else
static void
yy_stack_print (yybottom, yytop)
    yytype_int16 *yybottom;
    yytype_int16 *yytop;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}

/* Prevent warnings from -Wmissing-prototypes.  */
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*-------------------------.
| yyparse or yypush_parse.  |
`-------------------------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{


    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       `yyss': related to states.
       `yyvs': related to semantic values.

       Refer to the stacks thru separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yytoken = 0;
  yyss = yyssa;
  yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */
  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss_alloc, yyss);
	YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 15:

/* Line 1455 of yacc.c  */
#line 142 "cdl.yacc"
    { Pack_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 146 "cdl.yacc"
    { Pack_End(); ;}
    break;

  case 22:

/* Line 1455 of yacc.c  */
#line 156 "cdl.yacc"
    { Pack_Use((yyvsp[(1) - (1)].str)); ;}
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 157 "cdl.yacc"
    { Pack_Use((yyvsp[(3) - (3)].str)); ;}
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 165 "cdl.yacc"
    { Interface_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 180 "cdl.yacc"
    {Interface_Use((yyvsp[(1) - (1)].str));;}
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 181 "cdl.yacc"
    { Interface_Use((yyvsp[(3) - (3)].str)); ;}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 189 "cdl.yacc"
    { Interface_Package((yyvsp[(2) - (3)].str)); ;}
    break;

  case 42:

/* Line 1455 of yacc.c  */
#line 196 "cdl.yacc"
    { Method_TypeName(); ;}
    break;

  case 44:

/* Line 1455 of yacc.c  */
#line 197 "cdl.yacc"
    {Interface_Method((yyvsp[(3) - (5)].str));;}
    break;

  case 45:

/* Line 1455 of yacc.c  */
#line 200 "cdl.yacc"
    {Interface_Method("");;}
    break;

  case 46:

/* Line 1455 of yacc.c  */
#line 201 "cdl.yacc"
    {Interface_Method("");;}
    break;

  case 47:

/* Line 1455 of yacc.c  */
#line 202 "cdl.yacc"
    {Interface_Method("");;}
    break;

  case 49:

/* Line 1455 of yacc.c  */
#line 206 "cdl.yacc"
    { CDLerror("in interface, method declaration can not have a 'returns' clause"); ;}
    break;

  case 50:

/* Line 1455 of yacc.c  */
#line 210 "cdl.yacc"
    { Schema_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 51:

/* Line 1455 of yacc.c  */
#line 213 "cdl.yacc"
    { Schema_End(); ;}
    break;

  case 59:

/* Line 1455 of yacc.c  */
#line 226 "cdl.yacc"
    { Schema_Package((yyvsp[(2) - (3)].str)); ;}
    break;

  case 60:

/* Line 1455 of yacc.c  */
#line 227 "cdl.yacc"
    { Schema_Class(); ;}
    break;

  case 61:

/* Line 1455 of yacc.c  */
#line 232 "cdl.yacc"
    { Engine_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 67:

/* Line 1455 of yacc.c  */
#line 247 "cdl.yacc"
    { Engine_Schema((yyvsp[(3) - (3)].str)); ;}
    break;

  case 74:

/* Line 1455 of yacc.c  */
#line 258 "cdl.yacc"
    { Engine_Interface((yyvsp[(2) - (3)].str)); ;}
    break;

  case 75:

/* Line 1455 of yacc.c  */
#line 263 "cdl.yacc"
    { Component_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 76:

/* Line 1455 of yacc.c  */
#line 267 "cdl.yacc"
    { Component_End(); ;}
    break;

  case 84:

/* Line 1455 of yacc.c  */
#line 283 "cdl.yacc"
    { Component_Interface((yyvsp[(2) - (5)].str),(yyvsp[(4) - (5)].str)); ;}
    break;

  case 85:

/* Line 1455 of yacc.c  */
#line 289 "cdl.yacc"
    { Client_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 91:

/* Line 1455 of yacc.c  */
#line 304 "cdl.yacc"
    { Client_Use ( (yyvsp[(1) - (1)].str) ); ;}
    break;

  case 92:

/* Line 1455 of yacc.c  */
#line 305 "cdl.yacc"
    { Client_Use ( (yyvsp[(3) - (3)].str) ); ;}
    break;

  case 94:

/* Line 1455 of yacc.c  */
#line 309 "cdl.yacc"
    { Client_End(); ;}
    break;

  case 95:

/* Line 1455 of yacc.c  */
#line 310 "cdl.yacc"
    { Client_End(); ;}
    break;

  case 100:

/* Line 1455 of yacc.c  */
#line 320 "cdl.yacc"
    { Client_Interface((yyvsp[(2) - (3)].str)); ;}
    break;

  case 102:

/* Line 1455 of yacc.c  */
#line 324 "cdl.yacc"
    { Method_TypeName(); ;}
    break;

  case 104:

/* Line 1455 of yacc.c  */
#line 325 "cdl.yacc"
    {Client_Method((yyvsp[(3) - (5)].str),1);;}
    break;

  case 105:

/* Line 1455 of yacc.c  */
#line 326 "cdl.yacc"
    {Client_Method((yyvsp[(3) - (7)].str),1);;}
    break;

  case 106:

/* Line 1455 of yacc.c  */
#line 329 "cdl.yacc"
    {Client_Method("",1);;}
    break;

  case 107:

/* Line 1455 of yacc.c  */
#line 330 "cdl.yacc"
    {Client_Method("",1);;}
    break;

  case 108:

/* Line 1455 of yacc.c  */
#line 331 "cdl.yacc"
    {Client_Method("",1);;}
    break;

  case 109:

/* Line 1455 of yacc.c  */
#line 332 "cdl.yacc"
    {Client_Method("",1);;}
    break;

  case 110:

/* Line 1455 of yacc.c  */
#line 333 "cdl.yacc"
    {Client_Method("",-1);;}
    break;

  case 111:

/* Line 1455 of yacc.c  */
#line 334 "cdl.yacc"
    {Client_Method("",-1);;}
    break;

  case 113:

/* Line 1455 of yacc.c  */
#line 338 "cdl.yacc"
    { CDLerror("in client, method declaration can not have a 'returns' clause"); ;}
    break;

  case 114:

/* Line 1455 of yacc.c  */
#line 342 "cdl.yacc"
    { Executable_Begin((yyvsp[(2) - (3)].str)); ;}
    break;

  case 118:

/* Line 1455 of yacc.c  */
#line 350 "cdl.yacc"
    {  Executable_End(); ;}
    break;

  case 119:

/* Line 1455 of yacc.c  */
#line 351 "cdl.yacc"
    { Executable_End(); ;}
    break;

  case 122:

/* Line 1455 of yacc.c  */
#line 358 "cdl.yacc"
    { ExecFile_Begin((yyvsp[(2) - (2)].str)); ;}
    break;

  case 123:

/* Line 1455 of yacc.c  */
#line 362 "cdl.yacc"
    { ExecFile_End(); ;}
    break;

  case 128:

/* Line 1455 of yacc.c  */
#line 373 "cdl.yacc"
    { ExecFile_Schema((yyvsp[(3) - (3)].str)); ;}
    break;

  case 133:

/* Line 1455 of yacc.c  */
#line 384 "cdl.yacc"
    {ExecFile_AddUse((yyvsp[(1) - (3)].str));;}
    break;

  case 134:

/* Line 1455 of yacc.c  */
#line 387 "cdl.yacc"
    {ExecFile_SetUseType(CDL_LIBRARY); ;}
    break;

  case 135:

/* Line 1455 of yacc.c  */
#line 388 "cdl.yacc"
    {ExecFile_SetUseType(CDL_EXTERNAL); ;}
    break;

  case 140:

/* Line 1455 of yacc.c  */
#line 399 "cdl.yacc"
    { ExecFile_AddComponent((yyvsp[(1) - (3)].str)); ;}
    break;

  case 141:

/* Line 1455 of yacc.c  */
#line 401 "cdl.yacc"
    { ExecFile_SetLang(CDL_CPP); ;}
    break;

  case 143:

/* Line 1455 of yacc.c  */
#line 405 "cdl.yacc"
    { ExecFile_SetLang(CDL_CPP); ;}
    break;

  case 144:

/* Line 1455 of yacc.c  */
#line 406 "cdl.yacc"
    { ExecFile_SetLang(CDL_FOR); ;}
    break;

  case 145:

/* Line 1455 of yacc.c  */
#line 407 "cdl.yacc"
    { ExecFile_SetLang(CDL_C); ;}
    break;

  case 146:

/* Line 1455 of yacc.c  */
#line 408 "cdl.yacc"
    { ExecFile_SetLang(CDL_OBJ); ;}
    break;

  case 174:

/* Line 1455 of yacc.c  */
#line 460 "cdl.yacc"
    { Add_Std_Ancestors(); ;}
    break;

  case 175:

/* Line 1455 of yacc.c  */
#line 461 "cdl.yacc"
    { Add_Std_Uses(); ;}
    break;

  case 178:

/* Line 1455 of yacc.c  */
#line 478 "cdl.yacc"
    { Add_Std_Ancestors(); ;}
    break;

  case 179:

/* Line 1455 of yacc.c  */
#line 479 "cdl.yacc"
    { Add_Std_Uses(); ;}
    break;

  case 190:

/* Line 1455 of yacc.c  */
#line 505 "cdl.yacc"
    { Set_Item((yyvsp[(1) - (1)].str)); ;}
    break;

  case 207:

/* Line 1455 of yacc.c  */
#line 531 "cdl.yacc"
    { Add_Type(); ;}
    break;

  case 208:

/* Line 1455 of yacc.c  */
#line 532 "cdl.yacc"
    { Add_Type(); ;}
    break;

  case 209:

/* Line 1455 of yacc.c  */
#line 534 "cdl.yacc"
    { Type_Name((yyvsp[(1) - (1)].str)); Type_Pack_Blanc(); ;}
    break;

  case 210:

/* Line 1455 of yacc.c  */
#line 535 "cdl.yacc"
    { Type_Name((yyvsp[(1) - (2)].str)); ;}
    break;

  case 211:

/* Line 1455 of yacc.c  */
#line 535 "cdl.yacc"
    { Type_Pack((yyvsp[(4) - (4)].str)); ;}
    break;

  case 224:

/* Line 1455 of yacc.c  */
#line 603 "cdl.yacc"
    { Add_Enum((yyvsp[(1) - (1)].str)); ;}
    break;

  case 225:

/* Line 1455 of yacc.c  */
#line 604 "cdl.yacc"
    { Add_Enum((yyvsp[(3) - (3)].str)); ;}
    break;

  case 227:

/* Line 1455 of yacc.c  */
#line 610 "cdl.yacc"
    { add_cpp_comment_to_method(); ;}
    break;

  case 231:

/* Line 1455 of yacc.c  */
#line 617 "cdl.yacc"
    { Set_Method((yyvsp[(1) - (1)].str)); ;}
    break;

  case 236:

/* Line 1455 of yacc.c  */
#line 624 "cdl.yacc"
    { add_cpp_comment_to_method(); ;}
    break;

  case 282:

/* Line 1455 of yacc.c  */
#line 738 "cdl.yacc"
    { Add_Value((yyvsp[(1) - (1)].str),INTEGER); ;}
    break;

  case 283:

/* Line 1455 of yacc.c  */
#line 739 "cdl.yacc"
    { Add_Value((yyvsp[(1) - (1)].str),REAL); ;}
    break;

  case 284:

/* Line 1455 of yacc.c  */
#line 740 "cdl.yacc"
    { Add_Value((yyvsp[(1) - (1)].str),STRING); ;}
    break;

  case 285:

/* Line 1455 of yacc.c  */
#line 741 "cdl.yacc"
    { Add_Value((yyvsp[(1) - (1)].str),LITERAL); ;}
    break;

  case 286:

/* Line 1455 of yacc.c  */
#line 742 "cdl.yacc"
    { Add_Value((yyvsp[(1) - (1)].str),IDENTIFIER); ;}
    break;

  case 311:

/* Line 1455 of yacc.c  */
#line 790 "cdl.yacc"
    { Begin_List_Int((yyvsp[(1) - (1)].str)); ;}
    break;

  case 312:

/* Line 1455 of yacc.c  */
#line 791 "cdl.yacc"
    { Make_List_Int((yyvsp[(3) - (3)].str)); ;}
    break;

  case 314:

/* Line 1455 of yacc.c  */
#line 797 "cdl.yacc"
    { CDL_MustNotCheckUses(); ;}
    break;

  case 315:

/* Line 1455 of yacc.c  */
#line 797 "cdl.yacc"
    { CDL_MustCheckUses(); ;}
    break;

  case 321:

/* Line 1455 of yacc.c  */
#line 807 "cdl.yacc"
    { Method_TypeName(); ;}
    break;

  case 323:

/* Line 1455 of yacc.c  */
#line 809 "cdl.yacc"
    { Add_FriendExtMet((yyvsp[(3) - (4)].str)); ;}
    break;

  case 337:

/* Line 1455 of yacc.c  */
#line 838 "cdl.yacc"
    { add_name_to_list((yyvsp[(1) - (1)].str)); ;}
    break;

  case 338:

/* Line 1455 of yacc.c  */
#line 839 "cdl.yacc"
    { add_name_to_list((yyvsp[(3) - (3)].str)); ;}
    break;

  case 340:

/* Line 1455 of yacc.c  */
#line 843 "cdl.yacc"
    {(yyval.str)[0] = '\0';;}
    break;

  case 341:

/* Line 1455 of yacc.c  */
#line 850 "cdl.yacc"
    {set_inc_state();;}
    break;

  case 342:

/* Line 1455 of yacc.c  */
#line 851 "cdl.yacc"
    {restore_state();;}
    break;

  case 343:

/* Line 1455 of yacc.c  */
#line 853 "cdl.yacc"
    {Interface_Class();;}
    break;

  case 344:

/* Line 1455 of yacc.c  */
#line 854 "cdl.yacc"
    {Interface_End();;}
    break;

  case 345:

/* Line 1455 of yacc.c  */
#line 856 "cdl.yacc"
    {Engine_End();;}
    break;

  case 346:

/* Line 1455 of yacc.c  */
#line 858 "cdl.yacc"
    {Alias_Begin();;}
    break;

  case 347:

/* Line 1455 of yacc.c  */
#line 859 "cdl.yacc"
    {Alias_Type();;}
    break;

  case 348:

/* Line 1455 of yacc.c  */
#line 860 "cdl.yacc"
    {Alias_End();;}
    break;

  case 349:

/* Line 1455 of yacc.c  */
#line 862 "cdl.yacc"
    {Pointer_Begin();;}
    break;

  case 350:

/* Line 1455 of yacc.c  */
#line 863 "cdl.yacc"
    {Pointer_Type();;}
    break;

  case 351:

/* Line 1455 of yacc.c  */
#line 864 "cdl.yacc"
    {Pointer_End();;}
    break;

  case 352:

/* Line 1455 of yacc.c  */
#line 866 "cdl.yacc"
    {Imported_Begin();;}
    break;

  case 353:

/* Line 1455 of yacc.c  */
#line 867 "cdl.yacc"
    {Imported_End();;}
    break;

  case 354:

/* Line 1455 of yacc.c  */
#line 869 "cdl.yacc"
    {Prim_Begin();;}
    break;

  case 355:

/* Line 1455 of yacc.c  */
#line 870 "cdl.yacc"
    {Prim_End();;}
    break;

  case 356:

/* Line 1455 of yacc.c  */
#line 872 "cdl.yacc"
    {Except_Begin();;}
    break;

  case 357:

/* Line 1455 of yacc.c  */
#line 873 "cdl.yacc"
    {Except_End();;}
    break;

  case 358:

/* Line 1455 of yacc.c  */
#line 875 "cdl.yacc"
    {Enum_Begin();;}
    break;

  case 359:

/* Line 1455 of yacc.c  */
#line 876 "cdl.yacc"
    {Enum_End();;}
    break;

  case 360:

/* Line 1455 of yacc.c  */
#line 878 "cdl.yacc"
    {Inc_Class_Dec();;}
    break;

  case 361:

/* Line 1455 of yacc.c  */
#line 879 "cdl.yacc"
    {Inc_GenClass_Dec();;}
    break;

  case 362:

/* Line 1455 of yacc.c  */
#line 881 "cdl.yacc"
    {GenClass_Begin();;}
    break;

  case 363:

/* Line 1455 of yacc.c  */
#line 882 "cdl.yacc"
    {Add_GenType();;}
    break;

  case 364:

/* Line 1455 of yacc.c  */
#line 883 "cdl.yacc"
    {Add_DynaGenType();;}
    break;

  case 365:

/* Line 1455 of yacc.c  */
#line 884 "cdl.yacc"
    {Add_Embeded();;}
    break;

  case 366:

/* Line 1455 of yacc.c  */
#line 885 "cdl.yacc"
    {GenClass_End();;}
    break;

  case 367:

/* Line 1455 of yacc.c  */
#line 887 "cdl.yacc"
    {InstClass_Begin();;}
    break;

  case 368:

/* Line 1455 of yacc.c  */
#line 888 "cdl.yacc"
    {Add_Gen_Class();;}
    break;

  case 369:

/* Line 1455 of yacc.c  */
#line 889 "cdl.yacc"
    {Add_InstType();;}
    break;

  case 370:

/* Line 1455 of yacc.c  */
#line 890 "cdl.yacc"
    {InstClass_End();;}
    break;

  case 371:

/* Line 1455 of yacc.c  */
#line 891 "cdl.yacc"
    {DynaType_Begin();;}
    break;

  case 372:

/* Line 1455 of yacc.c  */
#line 893 "cdl.yacc"
    {StdClass_Begin();;}
    break;

  case 373:

/* Line 1455 of yacc.c  */
#line 894 "cdl.yacc"
    {StdClass_End();;}
    break;

  case 374:

/* Line 1455 of yacc.c  */
#line 896 "cdl.yacc"
    {Add_Raises();;}
    break;

  case 375:

/* Line 1455 of yacc.c  */
#line 897 "cdl.yacc"
    {Add_Field();;}
    break;

  case 376:

/* Line 1455 of yacc.c  */
#line 898 "cdl.yacc"
    {Add_FriendMet();;}
    break;

  case 377:

/* Line 1455 of yacc.c  */
#line 899 "cdl.yacc"
    {Add_Friend_Class();;}
    break;

  case 378:

/* Line 1455 of yacc.c  */
#line 901 "cdl.yacc"
    {Construct_Begin();;}
    break;

  case 379:

/* Line 1455 of yacc.c  */
#line 902 "cdl.yacc"
    {InstMet_Begin();;}
    break;

  case 380:

/* Line 1455 of yacc.c  */
#line 903 "cdl.yacc"
    {ClassMet_Begin();;}
    break;

  case 381:

/* Line 1455 of yacc.c  */
#line 904 "cdl.yacc"
    {ExtMet_Begin();;}
    break;

  case 382:

/* Line 1455 of yacc.c  */
#line 905 "cdl.yacc"
    {Friend_Construct_Begin();;}
    break;

  case 383:

/* Line 1455 of yacc.c  */
#line 906 "cdl.yacc"
    {Friend_InstMet_Begin();;}
    break;

  case 384:

/* Line 1455 of yacc.c  */
#line 907 "cdl.yacc"
    {Friend_ClassMet_Begin();;}
    break;

  case 385:

/* Line 1455 of yacc.c  */
#line 908 "cdl.yacc"
    {Friend_ExtMet_Begin();;}
    break;

  case 386:

/* Line 1455 of yacc.c  */
#line 909 "cdl.yacc"
    {Add_Me();;}
    break;

  case 387:

/* Line 1455 of yacc.c  */
#line 910 "cdl.yacc"
    {Add_MetRaises();;}
    break;

  case 388:

/* Line 1455 of yacc.c  */
#line 911 "cdl.yacc"
    {Add_Returns();;}
    break;

  case 389:

/* Line 1455 of yacc.c  */
#line 912 "cdl.yacc"
    {MemberMet_End();;}
    break;

  case 390:

/* Line 1455 of yacc.c  */
#line 913 "cdl.yacc"
    {ExternMet_End();;}
    break;

  case 391:

/* Line 1455 of yacc.c  */
#line 915 "cdl.yacc"
    {Param_Begin();;}
    break;

  case 392:

/* Line 1455 of yacc.c  */
#line 917 "cdl.yacc"
    {End();;}
    break;

  case 393:

/* Line 1455 of yacc.c  */
#line 918 "cdl.yacc"
    {Set_In();;}
    break;

  case 394:

/* Line 1455 of yacc.c  */
#line 919 "cdl.yacc"
    {Set_Out();;}
    break;

  case 395:

/* Line 1455 of yacc.c  */
#line 920 "cdl.yacc"
    {Set_InOut();;}
    break;

  case 396:

/* Line 1455 of yacc.c  */
#line 921 "cdl.yacc"
    {Set_Mutable();;}
    break;

  case 397:

/* Line 1455 of yacc.c  */
#line 922 "cdl.yacc"
    {Set_Mutable_Any();;}
    break;

  case 398:

/* Line 1455 of yacc.c  */
#line 923 "cdl.yacc"
    {Set_Immutable();;}
    break;

  case 399:

/* Line 1455 of yacc.c  */
#line 924 "cdl.yacc"
    {Set_Priv();;}
    break;

  case 400:

/* Line 1455 of yacc.c  */
#line 925 "cdl.yacc"
    {Set_Defe();;}
    break;

  case 401:

/* Line 1455 of yacc.c  */
#line 926 "cdl.yacc"
    {Set_Redefined();;}
    break;

  case 402:

/* Line 1455 of yacc.c  */
#line 927 "cdl.yacc"
    {Set_Prot();;}
    break;

  case 403:

/* Line 1455 of yacc.c  */
#line 928 "cdl.yacc"
    {Set_Static();;}
    break;

  case 404:

/* Line 1455 of yacc.c  */
#line 929 "cdl.yacc"
    {Set_Virtual();;}
    break;

  case 405:

/* Line 1455 of yacc.c  */
#line 930 "cdl.yacc"
    {Set_Like_Me();;}
    break;

  case 406:

/* Line 1455 of yacc.c  */
#line 931 "cdl.yacc"
    {Set_Any();;}
    break;



/* Line 1455 of yacc.c  */
#line 3227 "cdl.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined(yyoverflow) || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}



/* Line 1675 of yacc.c  */
#line 932 "cdl.yacc"


