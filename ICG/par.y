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

char *intrcd[100];
int nextinstr=0;

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
        symbol_table[symbol_count].value = (strcmp(type, "b") == 0) ? (value == 0 ? 0 : 1) : value;
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
    //printf("%s\n", result);
    return result;
}

char *genA(const char* type, const char *id, const char *s) {
    size_t len = strlen(type) + strlen(id) + strlen(s) + 5;
    char *result = (char *)malloc(len);
    if (result) {
        snprintf(result, len, "%s %s = %s", type, id, s);
    }
    //printf("%s\n", result);
    return result;
}

char *genRT(const char* op1, const char *op2, const char *relop) {
    size_t len = strlen(op1) + strlen(op2) + strlen(relop) + 13;
    char *result = (char *)malloc(len);
    if (result) {
        snprintf(result, len, "if %s %s %s goto ", op1, relop, op2);
    }
    //printf("%s\n", result);
    return result;
}

void genGoto(int instr) {
	char* result = (char*)malloc(10);
	sprintf(result, "%s %d", "goto", instr);
    	intrcd[nextinstr++]=result;
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

    strcpy(result, s1);
    strcpy(result, "\n");
    strcat(result, s2);

    return result;
}

int* makelist(int next) {
    int* arr = (int *)malloc(sizeof(int) * 100);

    arr[0] = next;
    for (int i = 1; i < 100; i++) arr[i] = -1;
    return arr;
}

int* merge(int* a, int* b){
	if (a == NULL) return b;
	if (b == NULL) return a;
	
	int i=0;
	while(a[i]!=-1) i++;
	int j=0;
	while(b[j]!=-1) a[i++]=b[j++];
	return a;
}

void backpatch(int* arr, int instr){
	if(arr==NULL) return;
	int i=0;
	while(i<100 && arr[i]!=-1){
		int len=strlen(intrcd[arr[i]]) + 3;
		char *result = (char *)malloc(len);
		sprintf(result,"%s%d",intrcd[arr[i]],instr);
		intrcd[arr[i]]=result;
		i++;
	}

}


%}

%union {
    char *string;
    int value;
    struct st {
        int *next;
        //char *code;
    } state;
    struct e {
        char *addr;
        //char *code;
    } expr;
    struct b {
    	int *true;
    	int *false;
    	//char *code;
    } b;
    struct m {
    	int instr;
    } m;
    struct n{
    	int *next;
    } n;
    
}

%token <string> IDENTIFIER NUMBER RELATIONAL ASSIGNMENT SEMICOLON EXIT INTEGER BOOLEAN TRUE FALSE IF ELSE WHILE OR AND NOT RELOP
%type <state> S
%type <expr> E
%type <b> B
%type <m> M
%type <n> N L

%left '+' '-'
%left '*' '/'
%left AND
%left OR


%%
L:  L M S {backpatch($<n.next>1, $<m.instr>2); $<n.next>$ = $<state.next>3; for(int i=0;i<nextinstr;i++) printf("%d. %s\n",i, intrcd[i]);}
    | S {$<n.next>$ = $<state.next>1; for(int i=0;i<nextinstr;i++) printf("%d. %s\n",i, intrcd[i]);}
    ;
S:
    INTEGER IDENTIFIER ASSIGNMENT E SEMICOLON {
        //add_symbol($2, atoi($<expr.addr>4), "int");
        //$<state.code>$ = concat($<expr.code>4,genA("int" ,$<expr.addr>2 ,$<expr.addr>4));
        intrcd[nextinstr++] = genA("int", $<expr.addr>2,$<expr.addr>4);
        $<state.next>$=NULL;
    }
    | IDENTIFIER ASSIGNMENT E SEMICOLON {
    	//$<state.code>$ = concat($<expr.code>4,genA("", $<expr.addr>1,$<expr.addr>3));
        //update_symbol($1, atoi($<expr.addr>4)); printf("%s = %s\n", $1, $<expr.addr>4);
        intrcd[nextinstr++] = genA("", $<expr.addr>1,$<expr.addr>3);
        $<state.next>$=NULL;
        
    }
    | IF '(' B ')' M S N ELSE M S {backpatch($<b.true>3,$<m.instr>5); backpatch($<b.false>3,$<m.instr>9); $<state.next>$=merge($<n.next>7, merge($<state.next>6, $<state.next>10));}
    | IF '(' B ')' M S {backpatch($<b.true>3,$<m.instr>5); $<state.next>$=merge($<b.false>3, $<state.next>6);}
    | WHILE M '(' B ')' M S {backpatch($<state.next>7,$<m.instr>2); backpatch($<b.true>4,$<m.instr>6); $<state.next>$=$<b.false>4; genGoto($<m.instr>2);}
    | EXIT { return; }
    ;

E:
    E '+' E {
        $<expr.addr>$ = newtemp();
        //$<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " + "));
        intrcd[nextinstr++]=genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " + ");
        //printf("%s\n", $<expr.code>$);
    }
    | E '-' E {
        $<expr.addr>$ = newtemp();
        //$<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " - "));
        intrcd[nextinstr++]=genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " + ");
        //printf("%s\n", $<expr.code>$);
    }
    | E '*' E {
        $<expr.addr>$ = newtemp();
        //$<expr.code>$ = concat(concat($<expr.code>1, $<expr.code>3), genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " * "));
        intrcd[nextinstr++]=genE($<expr.addr>$, $<expr.addr>1, $<expr.addr>3, " + ");
        //printf("%s\n", $<expr.code>$);
    }
    | NUMBER {
        $<expr.addr>$ = strdup($1);
        //$<expr.code>$ = NULL;
    }
    | IDENTIFIER {
        $<expr.addr>$ = strdup($1);
        //$<expr.code>$ = NULL;
    }
    ;
    
B:
	E RELOP E	{$<b.true>$ = makelist(nextinstr); $<b.false>$ = makelist(nextinstr+1); intrcd[nextinstr++]= genRT($<expr.addr>1, $<expr.addr>3, $2); intrcd[nextinstr++]=strdup("goto ");}
    	| B AND M B	{$<b.true>$ = $<b.true>3; $<b.false>$=merge($<b.false>1, $<b.false>3); backpatch($<b.true>1, $<m.instr>3);}
    	| B OR M B	{$<b.false>$ = $<b.false>3; $<b.true>$=merge($<b.true>1, $<b.true>3); backpatch($<b.false>1, $<m.instr>3);}
    	//{$<b.code>$ = concat(concat(concat($<expr.code>1, $<expr.code>3), genRT($<expr.addr>1, $<expr.addr>3, ">=", "T")), genGoto("F"));}
    	//| TRUE		{$<b.code>$ = concat($<expr.code>1, $<expr.code>3, genRT($<expr.addr>1, $<expr.addr>2, "==", "T"), genGoto("F"));}
    	//| FALSE		{$<b.code>$ = concat($<expr.code>1, $<expr.code>3, genRT($<expr.addr>1, $<expr.addr>2, "==", "T"), genGoto("F"));}
    	;
    	
M:	{$<m.instr>$=nextinstr;}
	;

N: 	{$<n.next>$=makelist(nextinstr); intrcd[nextinstr++]=strdup("goto ");}
	;

%% 

int main() {
    printf("Enter the input: \n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

