%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 100

typedef struct {
    char *name;
    int value;
    char *type;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(char *name, int value, char *type) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
      	    if(strcmp(symbol_table[i].type, type) == 0){
      	    	printf("Variable already declared\n");
      	    	return;
      	    
      	    }
      	    
      	    printf("Variable name %s already used\n", name);
      	    return;
        }
    }
	
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        if (strcmp("bool", type)==0){symbol_table[symbol_count].value = (value==0)?0:1;} else symbol_table[symbol_count].value = value;
        symbol_table[symbol_count].type = strdup(type);
        printf("Added: %s = %d, type = %s\n", symbol_table[symbol_count].name, symbol_table[symbol_count].value, symbol_table[symbol_count].type);
        symbol_count++;
    } else {
        printf("Symbol table is full!\n");
    }
}

void update_symbol(char *name, int value){
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
	   symbol_table[i].value = value;
           printf("Updated: %s = %d\n", name, value);
           return;
        }
    }
    
    printf("Variable not declared\n");	
}

int get_symbol_value(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].value;
        }
    }
    printf("Error: Undefined variable %s\n", name);
    return 0;
}

void print_symbols() {
    printf("Symbol Table:\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("%s %s: %d\n",symbol_table[i].type, symbol_table[i].name, symbol_table[i].value);
    }
}


%}

%union {
    char *string;
    int value;
}


%token <string> IDENTIFIER NUMBER RELATIONAL ASSIGNMENT SEMICOLON EXIT INTEGER BOOLEAN TRUE FALSE IF ELSE OR AND NOT EQ NE LS GR LE GE
%type <value> E S B

%left '+' '-'
%left '*' '/'
%left LS LE
%left GR GE
%left EQ NE


%%
P:	P S
	| S
	;
S:
    INTEGER IDENTIFIER ASSIGNMENT E SEMICOLON {add_symbol($2, $4,"int");}
    | BOOLEAN IDENTIFIER ASSIGNMENT B SEMICOLON {add_symbol($2, $4,"bool");}
    | IDENTIFIER ASSIGNMENT E SEMICOLON {update_symbol($1, $3);}
    | E SEMICOLON { printf("Expression result: %d\n", $1);}
    | EXIT	{return ;}
    ;

E:
    	E '+' E 	{$$ = $1 + $3;}
    	| E '-' E 	{$$ = $1 - $3;}
    	| E '*' E 	{$$ = $1 * $3;}
    	| NUMBER 	{$$ = atoi($1);}
    	| IDENTIFIER 	{$$ = get_symbol_value($1);}
    	| B
    	;
    	
B:
	E EQ E		{$$ = $1==$3;}
    	| E NE E 	{$$ = $1 != $3;}
    	| E LS E	{$$ = $1 < $3;}
    	| E GR E	{$$ = $1 > $3;}
    	| E LE E	{$$ = $1 <= $3;}
    	| E GE E	{$$ = $1 >= $3;}
    	| TRUE		{$$ = 1;}
    	| FALSE		{$$ = 0;}
    	

%%

int main() {
    printf("Enter the input: \n");
    yyparse();
    print_symbols();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

