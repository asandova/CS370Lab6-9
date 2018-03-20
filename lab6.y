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
%type <node> statement DEC IFELSE
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

DL	:	DEC  { $$=$1;}   /*  Declaration-list -> Declaration { Declaration} */
        |      DEC DL   {
			$1->next=$2;
			$$ = $1; /*left connect declarations */
                        if (mydebug) ASTprint(0,$1);
                        if (mydebug) ASTprint(0,$2);
			}
        ;

DEC	: VARDEC  {$$=$1;} 
        | FUNDEC  {$$=$1;} /*  Declaration -> Variable-Declaration | Function-Declaration */
        ;

VARDEC	: typespec ID  ';' { /* search symbol table for ID
                                insert if OK, then add the pointer from 
                                insertion into the  ASTnode to have reference
                                to the symbol table entry */
                            $$=ASTCreateNode(VARDEC); 
                            $$->name=$2; /* this changes to symbol table*/
                           } 
 	| typespec ID  '[' NUM ']' ';'
                  { /* search symbol table for ID, if not, place in there with size of array*/
                            $$=ASTCreateNode(VARDEC); 
			    $$->operator=$1;
                            $$->name=$2; /* this changes to symbol table*/
                            $$->value=$4; /* remember dimension*/
                            printf("found an array declaration \n");
                  }         
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
		$$->name=$2; /* this changes to symbol table*/
		$$->s1 = $4;		
		$$->s2 = $6; /* compound statement */
		printf("Function declaration found.\n");		
		} 
        ;

params	: VOID	{
		$$=NULL;			
		}
        | paramlist{
		$$=$1;
		}
        ;

paramlist	: param {$$=$1;}
                | param ',' paramlist{
			$1->next = $3;
			$$ = $1;
			}  
              	;

param	:	typespec ID{
			$$=ASTCreateNode(PARAM);
			$$->operator= $1;
			$$->name = $2;
		
		}
	|	typespec ID '[' NUM ']'{
			$$=ASTCreateNode(PARAM);
			$$->operator = $1;
			$$->name = $2;
			//...
		}
	;

   /* need to fix this to include local declarations into symbol table*/
compoundstmt	: '{' localdeclarations statementlist '}'{
			$$=ASTCreateNode(BLOCK);
                        $$->left=$2;
			$$->right=$3;
                        }
 	      	;

localdeclarations 	:  VARDEC localdeclarations {
				$1->next=$2;
				$$=$1;
				}
                  	| /* empty */ {$$=NULL;}
			;

/* for statements , left is the next statement, right is what this statement is */
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
                        $$->right=$1;
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
			$$=ASTCreateNode(IFSTMT);
                        $$->s1=$3;
			$$->s2=$5;
			$$->s3=$6;
                	}
             	;

IFELSE		: /*empty*/  { $$=NULL; }
		| statement  { $$=$1; }
		;

iterationstmt	: WHILE '(' expression ')' statement{
			$$=ASTCreateNode(WHILESTMT);
			$$->s1=$3;
			$$->s2=$5;
			}
               	;

returnstmt 	: RETURN ';'  { $$=ASTCreateNode(RETURNSTMT);}
            	| RETURN expression  ';'{
			$$=ASTCreateNode(RETURN);
			$$->s1=$2;
		     	}              
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


var	: ID	{
			$$=ASTCreateNode(IDENT);
			$$->name = $1;
		}
                /* we want to create a NODE called IDENTIFIER with a pointer to the SYMBOL table */
                 
	| ID  '[' expression ']'{
		$$=ASTCreateNode(IDENT);
	        $$->name=$1; /*change this to pointer to symbol table */
		$$->s1=$3;
		}
    	;


simpleexpression	: additiveexpression  {$$=$1;}
                 	| additiveexpression relop additiveexpression {
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
                    	| term  addop additiveexpression{
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
     	| factor  multop term{
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

arglist 	: expression  {$$=$1;}
         	| expression ',' arglist {
            		$$=ASTCreateNode(ARGLIST);
            		$$->s1=$1;
            		$$->next=$3;
           		}
         	;


%%	/* end of rules, start of program */
main(int argv, char * argc[])
{ 
  if (argv > 2) mydebug=1;
  yyparse();
  fprintf(stderr,"the input has been syntactically checked\n");
  ASTprint(0,program);  /* this is where we can do things with the AST like print it or process it */
}
