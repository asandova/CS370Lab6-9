/*   Abstract syntax tree code

     This code is used to define an AST node, 
    routine for printing out the AST
    defining an enumerated type so we can figure out what we need to
    do with this.  The ENUM is basically going to be every non-terminal
    and terminal in our language.

    Shaun Cooper February 2015

    Edited By: August B. Sandoval
    Class: CS370
    Lab: 6
    File: AST.c

*/

#include<stdio.h>
#include<malloc.h>
#include "AST.h"
//#include "symtable.h"
static int mydebug;

/* uses malloc to create an ASTnode and passes back the heap address of the newly created node */
ASTnode *ASTCreateNode(enum ASTtype mytype)
{
    ASTnode *p;
    if (mydebug) fprintf(stderr,"Creating AST Node \n");
    p=(ASTnode *)malloc(sizeof(ASTnode));
    p->node = NULL;
    p->type=mytype;
    p->next = NULL;
    p->left=NULL;
    p->right=NULL;
    p->s1=NULL;
    p->s2=NULL;
    p->value=0;
    return(p);
}

/* attach q to the left most part of p */
void ASTattachleft(ASTnode *p,ASTnode *q)
{
	p->left = q;
}



/*  Print out the abstract syntax tree */
void ASTprint(int level,ASTnode *p)
{
   int i;
   //printf("in ASRprint\n");
   if (p == NULL ) return;
   else
     { 
     for (i=0;i<level;i++) printf("   "); /* print tabbing blanks */
      
       switch (p->type) {
        case VARDEC :
		printf("Declaration: ");
                if (p->value > 0){
			printf("Array ");
			switch(p->datatype){
				case INTTYPE:
					printf("INT ");
					break;
				case VOIDTYPE:
					printf("VOID ");
					break;
				default:
					printf("Unknown datatype");
					break;
			}
                	printf("%s[%d]",p->name,p->value);
                }
		else{
			printf("Variable ");
			switch(p->datatype){
				case INTTYPE:
					printf("INT ");
					break;
				case VOIDTYPE:
					printf("VOID ");
					break;
				default:
					printf("Unknown datatype");
					break;
			}
			printf("%s", p->name);
		}
		printf("\n");
		ASTprint(level,p->next);
                break;
	case FUNCTIONDEC:
		printf("Declaration: ",p->name);	
		switch(p->datatype){
			case INTTYPE:
				printf("INT ");
				break;
			case VOIDTYPE:
				printf("VOID ");
				break;
			default:
				printf("unknown data Type ");
				break;
		}
		printf("Function %s\n", p->name);
		for (i=0;i<level+1;i++) printf("   ");
		printf("Paramater(s):\n");
		if(p->s1 != NULL)
			ASTprint(level+2,p->s1);
		else{
			for (i=0;i<level+2;i++) printf("   ");	 
			printf("VOID\n");
		}
		ASTprint(level+1, p->s2);
		printf("Declaration END: Function %s\n",p->name);
		ASTprint(level,p->next);		
		break;
	case PARAM:
		printf("Paramater: ", p->name);
		switch(p->datatype){
			case INTTYPE:
				printf("INT ");
				break;
			case VOIDTYPE:
				printf("VOID ");
				break;
			default:
				break;
		}
		printf("%s", p->name);
		if(p->value > 0){
			printf("[%d]", p->value);
		}
		printf("\n");
		ASTprint(level, p->next);
		break;
	case EXPR:
		printf("Expression: " );
		switch(p->operator){
			case PLUS:
				printf("+");
				break;
			case MINUS:
				printf("-");
				break;
			case TIMES:
				printf("*");
				break;
			case DIVIDE:
				printf("/");
				break;
			case LESSTHAN:
				printf("<");
				break;
			case LESSTHANEQUAL:
				printf("<=");
				break;
			case GREATERTHAN:
				printf(">");
				break;
			case GREATERTHANEQUAL:
				printf(">=");
				break;
			case EQUAL:
				printf("==");
				break;
			case NOTEQUAL:
				printf("!=");
				break;
			default:
				printf("unknown op");
				break;
		}
		printf("\n");
		ASTprint(level+1, p->left);
		ASTprint(level+1, p->right);
		break;
	case EXPRSTMT:
		printf("Expression Statement:\n");
		ASTprint(level+1, p->s1);
		ASTprint(level, p->next);
		//printf("\n");
		break;
	case IDENT:
		printf("Identifier: ");
		if(p->s1 != NULL){
			printf("Array %s ",p->name);
			printf("[\n");
			ASTprint(level+1, p->s1);
			for (i=0;i<level;i++) printf("   ");
			printf("] Array End\n");
		}
		else
			printf("Variable %s\n", p->name);
		break;
	case IFSTMT:
		printf("IF Statement:\n" );
		for (i=0;i<level+1;i++) printf("   ");
		printf("Condition:\n");
		ASTprint(level+2, p->s1);
		for (i=0;i<level+1;i++) printf("   ");
		printf("Action Statement(s):\n");
		ASTprint(level+2, p->s2);
		if(p->s3 != NULL){
			for (i=0;i<level;i++) printf("   ");
			printf("ElSE Statement:\n");
			ASTprint(level+1, p->s3);
		}
		ASTprint(level,p->next);
		break;
	case WHILESTMT:
		printf("While statement:\n");
		for (i=0;i<level+1;i++) printf("   ");
		printf("Condition:\n");
		ASTprint(level+2, p->s1);
		for (i=0;i<level+1;i++) printf("   ");
		printf("Action Statement(s):\n");
		ASTprint(level+2, p->s2);
		ASTprint(level,p->next);
		break;
	case ASSIGN:
		printf("Assignment Statement:\n");
		for (i=0;i<level+1;i++) printf("   ");
		printf("Assigning:\n");
		ASTprint(level+2,p->s1);
		for (i=0;i<level+1;i++) printf("   ");
		printf("To:\n");
		ASTprint(level+2, p->s2);
		ASTprint(level,p->next);
		break;
	case RETURNSTMT:
		printf("Return Statement:\n");
		if(p->s1 == NULL){ 
	 		for (i=0;i<level+1;i++) printf("   ");	
			printf("Returning NULL\n");
		}
		else{ ASTprint(level+1, p->s1); }
		ASTprint(level, p->next);
		break;
	case READSTMT:
		printf("Read Statement:\n");
		ASTprint(level+1,p->s1);
		ASTprint(level,p->next);
		break;
	case WRITESTMT:
		printf("WRITE Statement:\n");
		ASTprint(level+1, p->s1);
		ASTprint(level, p->next);
		break;
	case NUMBER:
		printf("NUMBER with value: %d\n", p->value);
		break;
	case CALL:
		printf("Call: Function %s\n", p->name);
		for (i=0;i<level+1;i++) printf("   ");
		printf("Argument(s):\n");
		if(p->s1 != NULL)
			ASTprint(level+2,p->s1);
		else{
			for (i=0;i<level+2;i++) printf("   ");
			printf("VOID\n");
		}		
		break;
	case ARGLIST:
		printf("Argument:\n");
		ASTprint(level+1, p->s1);
		ASTprint(level, p->next);
		break;
	case BLOCK:
		printf("Block:\n");
		ASTprint(level+1, p->s1);
		ASTprint(level+1, p->s2);
		for (i=0;i<level;i++) printf("   ");
		printf("Block END\n");
		ASTprint(level,p->next);
		break;
        default: printf("unknown type in ASTprint\n");
		break;

       }
     }

}



/* dummy main program so I can compile for syntax error independently  
main()
{
}
/* */
