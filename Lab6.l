/*                 
                Class: CS 370
		Assignment: Lab 6
		Date: January 25, 2015
		Name: August B. Sandoval
		File: Lab6.l
*/
%{

int mydebug=1;
int linecount = 1;
#include "AST.h"
#include "y.tab.h"
%}


%%
while			{if (mydebug) fprintf(stderr,"WHILE found\n"); 

				return (WHILE);}
if			{if (mydebug) fprintf(stderr,"IF found\n"); 
				return (IF);}

else			{if (mydebug) fprintf(stderr,"ELSE found\n"); 
				return (ELSE);}

void 			{if (mydebug) fprintf(stderr,"VOID found\n"); 
				return (VOID);}

int			{if (mydebug) fprintf(stderr,"INT found\n"); 
				return (INT);}

read			{if (mydebug) fprintf(stderr,"READ found\n"); 
				return (READ);}

write			{if (mydebug) fprintf(stderr,"WRITE found\n"); 
				return (WRITE);}

return			{if (mydebug) fprintf(stderr,"RETURN found\n"); 
				return (RETURN);}

"<"			{if (mydebug) fprintf(stderr,"LESS THAN found\n"); 
				return (LT);}

">"			{if (mydebug) fprintf(stderr,"GREATERT HAN found\n"); 
				return (GT);}

"<="			{if (mydebug) fprintf(stderr,"LESS EQUAL found\n"); 
				return (LE);}

">="			{if (mydebug) fprintf(stderr,"GREATER EQUAL found\n"); 
				return (GE);}

"!="			{if (mydebug) fprintf(stderr,"NOT EQUAL found\n"); 
				return (NE);}

"=="			{if (mydebug) fprintf(stderr,"EQUAL found\n"); 
				return (EQ);}

[a-zA-Z][a-zA-Z]*	{if (mydebug) fprintf(stderr,"ID found\n"); 
                       		yylval.string=strdup(yytext); return(ID);}

[0-9][0-9]*		{if (mydebug) fprintf(stderr,"NUMBER found\n"); 
                       		yylval.value=atoi((const char *)yytext); return(NUM);}

[ \t]			{if (mydebug) fprintf(stderr,"Whitespace found\n");}

[=\-+*/%&|();\[\]\{\},] 		{ if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); 
                       				return (*yytext);}
\n 			{ if (mydebug) fprintf(stderr,"cariage return %c\n",*yytext);
				linecount = linecount + 1;}

%%

int yywrap(void)
{ return 1;}


