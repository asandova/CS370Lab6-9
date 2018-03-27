%{
/*
 *			**** CMINUS ****
 *
 *
 */

/* 
   This lab is designed for you to create YACC directives using the EBNF description of Cminus.

   You are to take the EBNF of CMINUS and create YACC rules that will syntically check if an input
   program is syntactically correct.  You DO NOT have to do any type checking or any checking if an ID 
   has been defined.  

   The nice part of YACC is that it will do the checking for you as long as you define things correctly.
   You will need to report any syntax errors on the appropriate line.  If possible, you should have YACC
    continue with the parsing until end of file

   You will need to ensure that you define your tokens properly and with the correct return values.

   Shaun Cooper
    January 2015

   Edited by: August B. Sandoval
   Class: CS370
   File: lab6.y
   Lab: 6
   Last Edit: Mar 25, 2018  

*/


	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "AST.h"
//#include "lex.yy.c"
int linecount;
int mydebug;

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line %d\n", s, linecount);
}


%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

%start P

%union {
      int value;
      char * string;
      ASTnode * node;  /* so we can build an AST */
      enum OPERATORS operator;
      
}

%token <value> NUM INT VOID WHILE IF THEN ELSE READ WRITE FOR RETURN LE GE EQ NE LT GT
%token <string> ID 

%type <node> P DL VARDEC FUNDEC compoundstmt readstmt statementlist var
%type <node> expressionstmt selectionstmt iterationstmt assignmentstmt
%type <node> returnstmt writestmt localdeclarations
%type <node> factor term expression simpleexpression additiveexpression
%type <node> call args arglist params param paramlist
%type <node> statement DEC IFELSE RETVAL ISARRAY ARGNEXT PARAMNEXT DLNEXT
%type <value> VARISARRAYDEC PARAMISARRAY
%type <operator> relop addop multop typespec

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS


%%	/* end specs, begin rules */

P	:	DL   /* PRogram -> Declartion-list */
                {program=$1;}
	;

DL	:	DEC DLNEXT { /*  Declaration-list -> Declaration { Declaration} */
			/*Performed Left Factor Removal*/
			$1->next=$2;
			$$=$1; /*left connect declarations */
                        if (mydebug) ASTprint(0,$1);
                        if (mydebug) ASTprint(0,$2);
			}
        ;
	/*Created DLNEXT during Left Factor Removal of DL*/
DLNEXT	: DL	{$$=$1;}
	| /*empty*/	{$$=NULL;}
	;

DEC	: VARDEC  {$$=$1;} 
        | FUNDEC  {$$=$1;} /*  Declaration -> Variable-Declaration | Function-Declaration */
        ;

VARDEC	: typespec ID  VARISARRAYDEC ';' { 
	/* 	search symbol table for ID
		insert if OK, then add the pointer from 
		insertion into the  ASTnode to have reference
		to the symbol table entry
	*/
	/*Performed Left Factor removal*/
	$$=ASTCreateNode(VARDEC); 
	$$->datatype=$1;
	$$->name=$2; /* this changes to symbol table*/
	$$->value= $3;                           
	}       
        ;

		/*Created VARISARRAYDEC during Left Factor Removal of VARDEC*/
VARISARRAYDEC	: '[' NUM ']'{ $$=$2;}
		| /*empty*/{$$=0;}
		;

typespec	: INT {$$=INTTYPE;}
                | VOID {$$=VOIDTYPE;}
                ;

FUNDEC	:  typespec ID '(' params ')' compoundstmt{ 
		/* search symbol table for ID
		   insert if OK, then add the pointer from 
                   insertion into the  ASTnode to have reference
                   to the symbol table entry */

		/* need to add paramater listing */
		
		$$=ASTCreateNode(FUNCTIONDEC);
		$$->datatype = $1;
		$$->name=$2; /* this changes to symbol table*/
		$$->s1 = $4;		
		$$->s2 = $6; /* compound statement */
		/*printf("Function declaration found.\n");*/		
		} 
        ;

params	: VOID	{
		$$=NULL;			
		}
        | paramlist{
		$$=$1;
		}
        ;

paramlist	: param PARAMNEXT{
			/*performed left factor removal*/
			$1->next = $2;
			$$ = $1;
			}  
              	;

		/*PARAMNEXT create during left factor removal of paramlist*/
PARAMNEXT	: ',' paramlist { $$=$2;}
		|/*empty*/ {$$=NULL;}
		;

param	: typespec ID PARAMISARRAY{
		/*Performed Left Factor removal*/
		$$=ASTCreateNode(PARAM);
		$$->datatype = $1;
		$$->name = $2;
		$$->value = $3;
		//...
	}
	;
		/*Created during Left Factor removal on param*/
PARAMISARRAY	: '[' NUM ']' {$$=$2;}
		| /*empty*/ {$$=0;}
		;

compoundstmt	: '{' localdeclarations statementlist '}'{
			$$=ASTCreateNode(BLOCK);
                        $$->s1=$2;
			$$->s2=$3;
                        }
 	      	;

localdeclarations 	:  VARDEC localdeclarations {
				$1->next=$2;
				$$=$1;
				}
                  	| /* empty */ {$$=NULL;}
			;

statementlist 	:  /* empty */ {$$=NULL;}
              	| statement statementlist{
			$1->next= $2;
			$$ = $1;		
			}
              	;

statement	: expressionstmt	{$$=$1;}
		| compoundstmt		{$$=$1;}
		| selectionstmt		{$$=$1;}
		| iterationstmt		{$$=$1;}
		| assignmentstmt	{$$=$1;}
		| returnstmt		{$$=$1;}
		| readstmt		{$$=$1;}
		| writestmt     	{$$=$1;}
                ;

expressionstmt 	: expression ';'  {
			$$=ASTCreateNode(EXPRSTMT);
                        $$->s1=$1;
			}
		| ';'  { $$=NULL;}
 		;

assignmentstmt 	: var '=' expressionstmt {
			$$=ASTCreateNode(ASSIGN);
                          /* Assignment statement  we leave left alone so that
                             it can be strung with other statements	*/ 
                        $$->s1=$1;
                        $$->s2=$3;
			}
               	;

selectionstmt	: IF '(' expression ')' statement IFELSE{
			/*Performed Left Factor removal*/			
			$$=ASTCreateNode(IFSTMT);
                        $$->s1=$3;
			$$->s2=$5;
			$$->s3=$6;
                	}
             	;
		/*Created IFELSE during Left Factor removal on selectionstmt*/
IFELSE		: /*empty*/  { $$=NULL; }
		| ELSE statement  { $$=$2; }
		;

iterationstmt	: WHILE '(' expression ')' statement{
			$$=ASTCreateNode(WHILESTMT);
			$$->s1=$3;
			$$->s2=$5;
			}
               	;

returnstmt 	: RETURN RETVAL  {
			/*Performed Left Factor removal*/
			$$=ASTCreateNode(RETURNSTMT);
			$$->s1=$2;
			}
		; 
	/*Created REVAL during Left Factor removal on returnstmt*/
RETVAL	: expression ';' {$$=$1;}
	| ';' { $$=NULL; }
	;

readstmt : READ var ';' { /* make sure variable is in symbol table */
                          /*  Create a ASTnode for this statement on the right */
                            $$=ASTCreateNode(READSTMT);
                          /* this will be pointer to symbol table */
                            $$->s1=$2;
                        }
          ;


writestmt : WRITE expression ';' { /* make sure variable is in symbol table */
                          /*  Create a ASTnode for this statement on the right */
				$$=ASTCreateNode(WRITESTMT);
				$$->s1=$2;                               
				}
          ;

expression :   simpleexpression {$$=$1;}
           ;

var	: ID ISARRAY{
		/*Performed Left Factor removal*/
		$$=ASTCreateNode(IDENT);
		$$->name = $1;
		$$->s1 = $2;		
	}
                /* we want to create a NODE called IDENTIFIER with a pointer to the SYMBOL table */
    	;
	/*Created ISARRAY during Left Factor removal on var*/
ISARRAY	: '[' expression ']'{ $$=$2; }
	| /*empty*/ {$$=NULL;}
	;


simpleexpression: additiveexpression  {$$=$1;}
		| simpleexpression relop additiveexpression {
			$$=ASTCreateNode(EXPR);
			$$->left=$1;
			$$->right=$3;
			$$->operator=$2;
		}
		;

relop 	: LE  {$$=LESSTHANEQUAL;}
      	| LT  {$$=LESSTHAN;}
      	| GT  {$$=GREATERTHAN;}
      	| GE  {$$=GREATERTHANEQUAL;}
      	| EQ  {$$=EQUAL;}
      	| NE  {$$=NOTEQUAL;}
      	;

additiveexpression	: term  {$$=$1;}
                    	| additiveexpression  addop term{
				$$=ASTCreateNode(EXPR);
				$$->left=$1;
				$$->operator=$2;
				$$->right=$3;
			}
                    	;

addop 	: '+'  {$$=PLUS;}
      	| '-'  {$$=MINUS;}
      	;

term	: factor{$$=$1;}
     	| term  multop factor{
		$$=ASTCreateNode(EXPR);
		$$->left=$1;
		$$->right=$3;
		$$->operator=$2;
	}
     	;

multop 	: '*' {$$=TIMES;}
       	| '/' {$$=DIVIDE;}
       	;

factor 	: '(' expression ')'  {$$=$2;}
      	| NUM  {
		$$=ASTCreateNode(NUMBER);
                $$->value=$1;
		}
       	| var  { $$=$1;}
       	| call { $$=$1;}
       	;

call 	: ID '(' args ')' { 
			$$=ASTCreateNode(CALL);
         		$$->s1=$3;
         		$$->name=$1;  /*symbol table check */
          	}
     	;

args 	: arglist {$$=$1;}
      	| {$$=NULL;} /* empty */
     	;

arglist : expression ARGNEXT{
		/*Performed Left Factor removal*/
		$$=ASTCreateNode(ARGLIST);
		$$->s1=$1;
		$$->next=$2;
	}
        ;
	/*Created during Left Factor removal on arglist*/
ARGNEXT	: ',' arglist { $$=$2;}
	| /*empty*/ { $$=NULL;}
	;

%%	/* end of rules, start of program */
main(int argv, char * argc[])
{ 
  if (argv > 2) mydebug=1;
  yyparse();
  fprintf(stderr,"the input has been syntactically checked\n");
  ASTprint(0,program);  /* this is where we can do things with the AST like print it or process it */
}
