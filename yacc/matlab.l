%{

/*
 * Lexical specification for the MATCH scanner written for
 * flex (GNU Flex version 2.5.4).
 *
 * Command-line options: -f
 */

#include   <stdio.h>
#include   <string.h>
#include   <ctype.h>
#include   <stdlib.h>


#include "basic.h"


#include "y.tab.h"


#define Return(a, b)    \
{ \
 DB1(DB_HPM_lex, "Source line: %d, returned token: "a".\n", \
 SourceLine); \
 return b; \
 }


void yyinsert_comma_in_input(const int);
unsigned int SourceLine = 1;

static int Depth;

%}


%option noyywrap
%s QuoteSC


HSPACE                          [ \t]
HSPACES                         {HSPACE}+
NEWLINE                         \n|\r|\f
NEWLINES                        {NEWLINE}+


ELLIPSIS                        \.\.\.
CONTINUATION                   {ELLIPSIS}[^\n\r\f]*{NEWLINE}?


COMMENT                        \%[^\n\r\f]*{NEWLINE}?


IDENTIFIER                     [a-zA-Z][_a-zA-Z0-9]*


DIGIT                          [0-9]
INTEGER                        {DIGIT}+
EXPONENT                       [DdEe][+-]?{DIGIT}+
MANTISSA                       ({DIGIT}+\.)|({DIGIT}*\.{DIGIT}+)
FLOATINGPOINT                  {MANTISSA}{EXPONENT}?
DOUBLE                         ({INTEGER}{EXPONENT})|{FLOATINGPOINT}
NUMBER                         {INTEGER}|{DOUBLE}
IMAGINARYUNIT                  [ij]


%%


"for"                          {
                                Return("FOR", FOR);
                                }


"end"                          {
                                Return("END", END);
                                }


"if"                           {
                                Return("IF", IF);
                                }


"elseif"                       {
                                Return("ELSEIF", ELSEIF);
                                }


"else"                         {
                                Return("ELSE", ELSE);
                                }


"global"                       {
                                Return("GLOBAL", GLOBAL);
                                }


"while"                       {
                               Return("WHILE", WHILE);
                               }


"function"                    {
                               Return("FUNCTION", FUNCTION);
                               }


"return"                      {
                               Return("RETURN", RETURN);
                               }


<INITIAL>’[^’\n\r\f]*’/’      {
                               yymore();
                               }


,                             {
                               BEGIN(INITIAL);

                               Return("’,’", ’,’);
                               }


;                             {
                               BEGIN(INITIAL);

                               Return("’;’", ’;’);
                               }


<INITIAL>’[^’\r\f\n]*’        {
                               register int i, size;
                               char* modified;

                               const int length = yyleng-2;

                               for (size = 0, i = 1;
                               i <= length; size++, i++)
                               if (*(yytext+i) == ’\’’)
                                  i++;

                               modified = alloc_string(size+1);
                               *(modified+size) = ’\0’;

                               for (size = 0, i = 1;
                               i <= length; size++, i++)
                               {
                                   *(modified+size) = *(yytext+i);

                                   if (*(yytext+i) == ’\’’)
                                      i++;
                                   }

                               yylval.text = modified;

                               Return("TEXT", TEXT);
                               }


{NUMBER}{IMAGINARYUNIT}       {
                               BEGIN(QuoteSC);

                               *(yytext+yyleng-1) = ’\0’;

                               yylval.imaginaryQ =
                               atof(yytext);

                               Return("IMAGINARY", IMAGINARY);
                               }


{DIGIT}+/\.[*/\\^]            {
                               yylval.integerQ =
                               atoi(yytext);

                               Return("INTEGER", INTEGER);
                               }


{DIGIT}+/\.’                  {
                               yylval.integerQ =
                               atoi(yytext);

                               Return("INTEGER", INTEGER);
                               }


{INTEGER}                     {
                               BEGIN(QuoteSC);

                               yylval.integerQ =
                               atoi(yytext);

                               yyinsert_comma_in_input(INTEGER);

                               Return("INTEGER", INTEGER);
                               }


{DOUBLE}                      {
                               BEGIN(QuoteSC);

                               yylval.doubleQ =
                               atof(yytext);

                               Return("DOUBLE", DOUBLE);
                               }


{HSPACES}                     {
                               BEGIN(INITIAL);
                               }


{CONTINUATION}                {
                               SourceLine++;
                               }


{NEWLINES}                    {
                               BEGIN(INITIAL);

                               SourceLine += yyleng;

                               Return("LINE", LINE);
                               }


{IDENTIFIER}                  {
                               BEGIN(QuoteSC);

                               yylval.symbol =
                               strcpy(alloc_string(yyleng+1),
                               yytext);

                               yyinsert_comma_in_input(IDENTIFIER);

                               Return("IDENTIFIER", IDENTIFIER);
                               }


{COMMENT}                     {
                               BEGIN(INITIAL);

                               SourceLine++;

                               Return("LINE", LINE);
                               }


&                               {
                                 BEGIN(INITIAL);

                                 Return("AND", AND);
                                 }


\|                              {
                                 BEGIN(INITIAL);

                                 Return("OR", OR);
                                 }


\<                              {
                                 BEGIN(INITIAL);

                                 Return("LTHAN", LTHAN);
                                 }


\<=                             {
                                 BEGIN(INITIAL);

                                 Return("LTHANE", LTHANE);
                                 }


>                               {
                                 BEGIN(INITIAL);

                                 Return("GTHAN", GTHAN);
                                 }


>=                              {
                                 BEGIN(INITIAL);

                                 Return("GTHANE", GTHANE);
                                 }


==                              {
                                 BEGIN(INITIAL);

                                 Return("EQUAL", EQUAL);
                                 }
~=                             {
                                BEGIN(INITIAL);

                                Return("UNEQUAL", UNEQUAL);
                                }


:                              {
                                BEGIN(INITIAL);

                                Return("’:’", ’:’);
                                }


\+                             {
                                BEGIN(INITIAL);

                                Return("’+’", ’+’);
                                }


-                              {
                                BEGIN(INITIAL);

                                Return("’-’", ’-’);
                                }


\*                             {
                                BEGIN(INITIAL);

                                Return("’*’", ’*’);
                                }


".*"                           {
                                BEGIN(INITIAL);

                                Return("EMUL", EMUL);
                                }


\/                             {
                                BEGIN(INITIAL);

                                Return("’/’", ’/’);
                                }


"./"                           {
                                BEGIN(INITIAL);


                                 Return("EDIV", EDIV);
                                 }


\\                              {
                                 BEGIN(INITIAL);

                                 Return("’\\’", ’\\’);
                                 }


\.\\                            {
                                 BEGIN(INITIAL);

                                 Return("ELEFTDIV", ELEFTDIV);
                                 }


{HSPACES}\.’                    {
                                 Return("LEXERROR", LEXERROR);
                                 }


\.’                             {
                                 BEGIN(QuoteSC);

                                 Return("TRANSPOSE", TRANSPOSE);
                                 }


\.^                             {
                                 BEGIN(INITIAL);

                                 Return("EPOWER", EPOWER);
                                 }


\^                              {
                                 BEGIN(INITIAL);

                                 Return("POWER", POWER);
                                 }


~                               {
                                 BEGIN(INITIAL);

                                 Return("NOT", NOT);
                                 }


<QuoteSC>’                     {
                                Return("CTRANSPOSE", CTRANSPOSE);
                                }


<INITIAL>’                     {
                                Return("LEXERROR", LEXERROR);
                                }


\[                             {
                                if (Depth)
                                   {
                                     Depth++;

                                    Return("’[’", ’[’);
                                    }

                                int current = 0, next = 0;
                                char* buffer = 0;
                                int level = 1, length = 0;

                                while (level &&
                                (current = yyinput()) != EOF)
                                {
                                  buffer =
                                  realloc_string(buffer, ++length);

                                 *(buffer+length-1) = current;

                                 if (current == ’[’)
                                    level++;

                                 if (current == ’]’)
                                    level--;
                                 }

                                if (level)
                                   {
                                     Return("LEXERROR", LEXERROR);
                                     }

                                while ((current = yyinput()) != EOF)
                                {
                                  buffer =
                                  realloc_string(buffer, ++length);

                                 *(buffer+length-1) = current;

                                 if (current != ’ ’ &&
                                 current != ’\t’)
                                    break;
                                 }

                                if ((next = yyinput()) != EOF)
                                   {
                                     buffer =
                                     realloc_string(buffer, ++length);

                                    *(buffer+length-1) = next;
                                    }


                                for (; length > 0; length--)
                                unput(*(buffer+length-1));

                                free(buffer);

                                Depth = 1;

                                if (current == ’=’ && next != ’=’)
                                   {
                                     Return("LD", LD);
                                     }
                                else
                                   {
                                     Return("’[’", ’[’);
                                     }
                                }


\]/{HSPACE}*=[^=]              {
                                BEGIN(INITIAL);

                                Depth--;

                                Return("RD", RD);
                                }


\]                             {
                                BEGIN(QuoteSC);

                                Depth--;

                                Return("’]’", ’]’);
                                }


\(                             {
                                BEGIN(INITIAL);


                                     Return("’(’", ’(’);
                                     }


\)                                  {
                                     BEGIN(QuoteSC);

                                     Return("’)’", ’)’);
                                     }


=                                   {
                                     BEGIN(INITIAL);

                                     Return("’=’", ’=’);
                                     }


.                                   {
                                     Return("LEXERROR", LEXERROR);
                                     }


%%


void yyinsert_comma_in_input(const int lastToken)
{
  int count, current, next;

    extern int BracketDelimiter;


    DB0(DB_HPM_lex, "Entering <yyinsert_comma_in_input> ...\n");

    if (!(BracketDelimiter == ’[’ || BracketDelimiter == LD))
       return;

    for (count = 1; ; count++)
    {
     current = yyinput();

    if (current != ’ ’ && current != ’\t’)
       break;
    }

    if (current ==   ’,’ || current ==   ’;’ || current == ’]’ ||
    current == ’*’   || current == ’^’   || current == ’:’ ||
    current == ’<’   || current == ’>’   || current == ’=’ ||
    current == ’&’   || current == ’|’   ||
current == ’/’ || current == ’\\’ ||
current == ’\n’ || current == ’\r’ || current == ’\f’ ||
current == ’%’ ||
(current == ’\’’ && count == 1))
   {
     unput(current);

     return;
     }

if (current == ’(’ &&
(BracketDelimiter == LD ||
(lastToken == IDENTIFIER && count == 1)))
   {
     unput(current);

     return;
     }

if (isalpha(current) &&
(lastToken == INTEGER || lastToken == DOUBLE) && count == 1)
   {
     unput(current);

     return;
     }


next = yyinput();
++count;


if (current == ’.’ &&
(next == ’\’’ || next == ’*’ || next == ’^’ ||
next == ’/’ || next == ’\\’ || next == ’.’))
   {
     unput(next);
     unput(’.’);

     if (next == ’\’’ && count > 2)
        unput(’ ’);

     return;
     }

if (current == ’~’ && next == ’=’)
   {
     unput(’=’);
     unput(’~’);

     return;
     }

if (current == ’+’ || current == ’-’)
   {
     if (count == 2 || next == ’ ’ || next == ’\t’)
        {
         unput(next);
         unput(current);

         return;
         }
     }

unput(next);
unput(current);
unput(’,’);
}
