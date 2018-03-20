/*   Abstract syntax tree code

     This code is used to define an AST node, 
    routine for printing out the AST
    defining an enumerated type so we can figure out what we need to
    do with this.  The ENUM is basically going to be every non-terminal
    and terminal in our language.

    Shaun Cooper February 2015

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
//... missing
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
		printf("Variable declaration with name \"%s\"",p->name);
                if (p->value > 0)
                	printf("[%d]",p->value);
                printf("\n");
                break;
//....missing
	case FUNCTIONDEC:
		printf("Function declaration with name \"%s\"\n",p->name);
		printf("With parameters:");
		ASTprint(level,p->s1);
		printf("\nFolowing statments:\n");
		ASTprint(level+1, p->s2);
		printf("\n");
		break;
	case PARAM:
		printf("%s, ", p->name);
		ASTprint(level, p->next);
		break;
	case EXPR:
		printf("Expression: " );
		printf("left: ");
		ASTprint(level, p->left);
		printf("operator:  ");
		printf("right:");
		ASTprint(level, p->right);
		break;
	case EXPRSTMT:
/*
		printf("Expression Statement:\n\t");
		printf("Left:");
		ASTprint(level, p->left);
		printf("right:");
		ASTprint(level, p->right);
		printf("\n");
*/
		break;
	case IDENT:
		printf("Identifier: %s", p->name);
		break;
	case IFSTMT:
//		printf("IF Statement:\n\t");
		break;
	case WHILESTMT:
		printf("While statement:\n");
		printf(" Expression: ");
		ASTprint(level, p->s1);
		printf("\nFollowing statments:\n");
		ASTprint(level+1, p->s2);
		break;
	case ASSIGN:
		printf("assignment:");
		ASTprint(0,p->s1);
		printf("=");
		ASTprint(0, p->s2);
		break;
	case RETURNSTMT:
		break;
	case READSTMT:
		break;
	case NUMBER:
//		printf("Number constant with value: %d\n", p->value);
		break;
	case CALL:
//		printf("Function call:\n\tName: %s\n", p->name);
//		printf("Args:");
//		ASTprint(level, p->right);
		break;
	case ARGLIST:
/*		printf("ArgList:\n\t");
		printf("Arg:");
		ASTprint(level, p->left);
		printf(", ");
		ASTprint(level, p->right);
*/		break;
	case BLOCK:
		printf("Block found\n");
		ASTprint(level+1, p->left);
		printf("\n");
		ASTprint(level+1, p->right);
		break;
        default: printf("unknown type in ASTprint\n");


       }
     }

}



/* dummy main program so I can compile for syntax error independently  
main()
{
}
/* */
