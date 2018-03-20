#ifndef SYMTABLE_H
#define SYMTABLE_H


enum nameType{
	VAR,
	FUNCT
};

struct SymbTab{
	char symbol[10];
	enum nameType type;
	int addr;
	struct SymbTab *next;
};


void Insert(char* sym, int addr, enum nameType type);
void Display();
void Delete(char lab[]);
int Search(char lab[]);

#endif
