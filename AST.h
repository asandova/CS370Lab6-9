#ifndef AST_H
#define AST_H
#include "symtable.h"

enum ASTtype {
	PROGRAM,
	VARDEC,
	INTTYPE,
	VOIDTYPE,
	IDENT,
	FUNCTIONDEC,
	EXPR,
	EXPRSTMT,
	IFSTMT,
	ASSIGN,
	RETURNSTMT,
	READSTMT,
	WRITESTMT,
	WHILESTMT,
	NUMBER,
	CALL,
	ARGLIST,
	BLOCK,
	PARAM
};


enum OPERATORS {
	PLUS,
	MINUS,
	TIMES,
	DIVIDE,
	LESSTHANEQUAL,
	LESSTHAN,
	GREATERTHAN,
	GREATERTHANEQUAL,
	EQUAL,
	NOTEQUAL
};

typedef struct ASTnodetype
{
     enum ASTtype type;
     enum OPERATORS operator;
     char * name;
     enum ASTtype datatype;/*Added a field for variable data type and Function return type*/
     int value;
     struct SymbTab *node;
     struct ASTnodetype *next,*left,*right; /* left is usually the connector for statements */
     struct ASTnodetype *s1,*s2, *s3 ; /* used for holding IF and WHILE components -- not very descriptive */
} ASTnode;

ASTnode *ASTCreateNode(enum ASTtype mytype);

void ASTattachleft(ASTnode *p,ASTnode *q);

void ASTprint(int level,ASTnode *p);
ASTnode *program;

#endif
