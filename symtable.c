/****
	File: symTable.c
	Original file from: forgetcode.com/C/101-Symbol-table
	Used in CS370 Lab 3
	Description:
		This file contains the implementation of a symbol table.
		Containing data structure and its helper functions.
	Modified: Feb 6, 2018
	Modified by: August B. Sandoval
	Modification:
		Added indentation
		inline comments
**/
#include<stdio.h>
//#include<conio.h>
#include<malloc.h>
#include<string.h>
#include<stdlib.h>
#include "symtable.h"
int size=0;
struct SymbTab *first,*last;

// Insert function definition
void Insert(char* sym, int addr, enum nameType type){
/**
*	The insert function is responsable for the creation and insertion of new Symbols in the symbol table
*	The function will check in the symbol being inserted in unique before inserting
*	If unique the function will allocat momery for the symbol using malloc
**/
		struct SymbTab *p;
		//This is where momory is allocated for the new symbol
		p=malloc(sizeof(struct SymbTab));
		strcpy(p->symbol,sym);
		p->type = type;
		p->addr = addr;		
		p->next=NULL;
		if(size==0){
			first=p;
			last=p;
		}
		else{
			last->next=p;
			last=p;
		}
		size++;
	//}
	printf("\n\tLabel inserted\n");
}
//Display funtion Definition
void Display(){
/**
*	Displays the entire symbol table
*	desplaying the lable , stmbol and the address of the symbol in that order
*/
	int i;
	struct SymbTab *p;
	p=first;
	printf("\n\tLABEL\t\tSYMBOL\t\tADDRESS\t\tTYPE\n");
	for(i=0;i<size;i++){
		printf("\t\t%s\t\t%d",p->symbol,p->addr);
		printf("\t\t%s\n", ( p->type == VAR ? "variable" : "function") );
		p=p->next;
	}
}
// Search function definition
int Search(char lab[]){
/**
*	The search functions will look for a given label in the symbol table>
*	The function will return the address of the label if found, otherwise returns -1
*/
	int i,flag=-1;
	struct SymbTab *p;
	p=first;
	for(i=0;i<size;i++){
		if(strcmp(p->symbol,lab)==0)
			flag=p->addr;
		p=p->next;
	}
	return flag;
}
// Delete function definition
void Delete(char lab[]){
/**
* 	The delete function will remove a symbol from the table
*/
	int a;
	struct SymbTab *p,*q;
	p=first;
	a=Search(lab);
	if(a==-1)
		printf("\n\tLabel not found\n");
	else{
		if(strcmp(first->symbol,lab)==0)
			first=first->next;
		else if(strcmp(last->symbol,lab)==0){
			q=p->next;
			while(strcmp(q->symbol,lab)!=0){
				p=p->next;
				q=q->next;
			}
			p->next=NULL;
			last=p;
		}
		else{
			q=p->next;
			while(strcmp(q->symbol,lab)!=0){
				p=p->next;
				q=q->next;
			}
			p->next=q->next;
		}
		size--;
		printf("\n\tAfter Deletion:\n");
		Display();
	}
}

