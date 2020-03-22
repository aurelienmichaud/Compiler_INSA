/* A Bison parser, made by GNU Bison 3.5.3.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    tMAIN = 258,
    tPRINTF = 259,
    tIDENTIFIER = 260,
    tVOID = 261,
    tINT = 262,
    tFLOAT = 263,
    tDOUBLE = 264,
    tCHAR = 265,
    tLONG = 266,
    tSIGNED = 267,
    tUNSIGNED = 268,
    tSHORT = 269,
    tCONST = 270,
    tINTEGER_NUMBER = 271,
    tFLOAT_NUMBER = 272,
    tIF = 273,
    tELSE = 274,
    tWHILE = 275,
    tSWITCH = 276,
    tFOR = 277,
    tDO = 278,
    tBREAK = 279,
    tCONTINUE = 280,
    tDEFAULT = 281,
    tRETURN = 282,
    tNEWLINE = 283,
    tSPACE = 284,
    tEQUAL = 285,
    tOP = 286,
    tCP = 287,
    tOCB = 288,
    tCCB = 289,
    tOB = 290,
    tCB = 291,
    tE_MARK = 292,
    tI_MARK = 293,
    tSEMI_C = 294,
    tCOMMA = 295,
    tCOLON = 296,
    tMUL = 297,
    tDIV = 298,
    tADD = 299,
    tSUB = 300,
    tMOD = 301
  };
#endif
/* Tokens.  */
#define tMAIN 258
#define tPRINTF 259
#define tIDENTIFIER 260
#define tVOID 261
#define tINT 262
#define tFLOAT 263
#define tDOUBLE 264
#define tCHAR 265
#define tLONG 266
#define tSIGNED 267
#define tUNSIGNED 268
#define tSHORT 269
#define tCONST 270
#define tINTEGER_NUMBER 271
#define tFLOAT_NUMBER 272
#define tIF 273
#define tELSE 274
#define tWHILE 275
#define tSWITCH 276
#define tFOR 277
#define tDO 278
#define tBREAK 279
#define tCONTINUE 280
#define tDEFAULT 281
#define tRETURN 282
#define tNEWLINE 283
#define tSPACE 284
#define tEQUAL 285
#define tOP 286
#define tCP 287
#define tOCB 288
#define tCCB 289
#define tOB 290
#define tCB 291
#define tE_MARK 292
#define tI_MARK 293
#define tSEMI_C 294
#define tCOMMA 295
#define tCOLON 296
#define tMUL 297
#define tDIV 298
#define tADD 299
#define tSUB 300
#define tMOD 301

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 83 "syntax.y"
 
		int integer_nb;
		float float_nb;
		char *string;
	

#line 156 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
