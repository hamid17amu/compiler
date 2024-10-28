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
            if (strcmp(symbol_table[i].type, type) == 0) {
                printf("Variable already declared\n");
                return;
            }
            printf("Variable name %s already used\n", name);
            return;
        }
    }

    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].value = (strcmp(type, "bool") == 0) ? (value == 0 ? 0 : 1) : value;
        symbol_table[symbol_count].type = strdup(type);
        printf("Added: %s = %d, type = %s\n", symbol_table[symbol_count].name, symbol_table[symbol_count].value, symbol_table[symbol_count].type);
        symbol_count++;
    } else {
        printf("Symbol table is full!\n");
    }
}

void update_symbol(char *name, int value) {
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
        printf("%s %s: %d\n", symbol_table[i].type, symbol_table[i].name, symbol_table[i].value);
    }
}

char *genE(const char *id, const char *s1, const char *s2, const char *s3) {
    size_t len = strlen(id) + strlen(s1) + strlen(s2) + strlen(s3) + 4;
    char *result = (char *)malloc(len);
    if (result) {
        snprintf(result, len, "%s = %s%s%s", id, s1, s3, s2);
    }
    printf("%s\n", result);
    return result;
}

char *genA(const char* type, const char *id, const char *s) {
    size_t len = strlen(type) + strlen(id) + strlen(s) + 5;
    char *result = (char *)malloc(len);
    if (result) {
        snprintf(result, len, "%s %s = %s", type, id, s);
    }
    printf("%s\n", result);
    return result;
}

char *newtemp() {
    static int counter = 0;
    char *temp = (char *)malloc(10);
    snprintf(temp, 10, "t%d", counter++);
    return temp;
}

char *concat(const char *s1, const char *s2) {
    if (!s1 && !s2) {
        return NULL;
    }
    if (!s1) {
        return strdup(s2);
    }
    if (!s2) {
        return strdup(s1);
    }

    size_t len1 = strlen(s1);
    size_t len2 = strlen(s2);
    char *result = (char *)malloc(len1 + len2 + 2);
    if (!result) {
        fprintf(stderr, "Error: Memory allocation failed.\n");
        return NULL;
    }

    // Copy s1 and s2 into the result
    strcpy(result, s1);
    strcpy(result, "\n");
    strcat(result, s2);

    return result;
}

%}

%union {
    char *string;
    int value;
    struct st {
        char *next;
        char *code;
    } state;
    struct e {
        char *addr;
        char *code;
    } expr;
}

%token <string> IDENTIFIER NUMBER RELATIONAL ASSIGNMENT SEMICOLON EXIT INTEGER BOOLEAN TRUE FALSE IF ELSE OR AND NOT EQ NE LS GR LE GE
%type <state> S
%type <expr> E
// Define B if needed
// %type <bool> B

%left '+' '-'
%left '*' '/'

%%
P: P S
    | S
    ;
S:
    INTEGER IDENTIFIER ASSIGNMENT E SEMICOLON {
        //add_symbol($2, atoi($<expr.addr>4), "int");
        $<state.code>$ = concat($<expr.code>4,genA("int" ,$<expr.addr>2 ,$<expr.addr>4));
    }
    | IDENTIFIER ASSIGNMENT E SEMICOLON {
    	$<state.code>$ = concat($<expr.code>4,genA("", $<expr.addr>1,$<expr.addr>3));
        //update_symbol($1, atoi($<expr.addr>4)); printf("%s = %s\n", $1, $<expr.addr>4);
    }
    | EXIT { return; }
    ;

E:
    E '+' E {
        $<expr.addr>$ = newtemp();
        $<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " + "));
        //printf("%s\n", $<expr.code>$);
    }
    | E '-' E {
        $<expr.addr>$ = newtemp();
        $<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " - "));
        //printf("%s\n", $<expr.code>$);
    }
    | E '*' E {
        $<expr.addr>$ = newtemp();
        $<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " * "));
        //printf("%s\n", $<expr.code>$);
    }
    | NUMBER {
        $<expr.addr>$ = strdup($1);
        $<expr.code>$ = NULL;
    }
    | IDENTIFIER {
        $<expr.addr>$ = strdup($1);
        $<expr.code>$ = NULL;
    }
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

