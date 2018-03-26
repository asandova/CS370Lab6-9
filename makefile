all: LAB6

LAB6: YACC AST.o symtable.o
	gcc y.tab.c lex.yy.c symtable.o AST.o -o Lab6

YACC: LEX
	yacc -d lab6.y

LEX: Lab6.l
	lex Lab6.l

AST.o: AST.h AST.c
	gcc -c AST.c

symtable.o: symtable.h symtable.c
	gcc -c symtable.c

clean:
	rm -rf y.tab.* 
	rm -rf *.o
	rm -rf lex.yy.c
