%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 100

typedef struct {
    char *name;
    int value;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(char *name, int value) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].value = value;
            printf("Updated: %s = %d\n", name, value);
            return;
        }
    }
	
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].value = value;
        symbol_count++;
        printf("Added: %s = %d\n", name, value);
    } else {
        printf("Symbol table is full!\n");
    }
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
        printf("%s: %d\n", symbol_table[i].name, symbol_table[i].value);
    }
}

%}

%union {
    char *string;
    int value;
}

%token <string> IDENTIFIER NUMBER RELATIONAL ASSIGNMENT SEMICOLON EXIT
%type <value> E T F S

%left '+' '-'
%left '*' '/'

%%
P:	P S
	| S
	;
S:
    IDENTIFIER ASSIGNMENT E SEMICOLON {add_symbol($1, $3);}
    | E SEMICOLON { printf("Expression result: %d\n", $1);}
    | EXIT	{return ;}
    ;

E:
    
    	| E '+' T 	{$$ = $1 + $3;}
    	| E '-' T 	{$$ = $1 - $3;}
    	| E RELATIONAL E {$$ = 0;}
    	| T 		{$$=$1;}
    	;
    	
T:	T '*' F 	{$$ = $1 * $3;}
	| F 	{$$ = $1;}
	;
	
F:	NUMBER 		{$$ = atoi($1);}
    	| IDENTIFIER 	{$$ = get_symbol_value($1);}
    	;

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

