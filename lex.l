%{
#include<stdio.h>

typedef enum {
    TOKEN_NUMBER,
    TOKEN_IDENTIFIER,
    TOKEN_RELATIONAL,
    TOKEN_ASSIGNMENT,
    TOKEN_DIGITS,
    TOKEN_FRACTION,
    TOKEN_EXPONENT,
    TOKEN_LETTER,
    TOKEN_DIGIT
} TokenType;

TokenType token_type;

void print_token(TokenType type, const char* value) {
    switch (type) {
        case TOKEN_NUMBER: printf("number: %s\n", value); break;
        case TOKEN_IDENTIFIER: printf("identifier: %s\n", value); break;
        case TOKEN_RELATIONAL: printf("relop: %s\n", value); break;
        case TOKEN_ASSIGNMENT: printf("assign: %s\n", value); break;
        case TOKEN_DIGITS: printf("digits: %s\n", value); break;
        case TOKEN_FRACTION: printf("fraction: %s\n", value); break;
        case TOKEN_EXPONENT: printf("exponent: %s\n", value); break;
        case TOKEN_LETTER: printf("letter: %s\n", value); break;
        case TOKEN_DIGIT: printf("digit: %s\n", value); break;
    }
}

%}

digit		[0-9]
letter		[a-zA-Z]
identifier	{letter}({letter}|{digit})*
digits 		{digit}+
fraction 	(\.{digits})?
exponent	(E[+-]?{digits})?
number		{digits}{fraction}{exponent}
rel_op_eq    	(==)
rel_op_neq   	(!=)
rel_op_leq   	(<=)
rel_op_geq   	(>=)
rel_op_lt    	(<)
rel_op_gt    	(>)
assignment    	(=)
whitesp		[ \t\n]

%%
{digit}       { token_type = TOKEN_DIGIT; print_token(token_type, yytext); }
{letter}      { token_type = TOKEN_LETTER; print_token(token_type, yytext); }
{identifier}  { token_type = TOKEN_IDENTIFIER; print_token(token_type, yytext); }
{digits}      { token_type = TOKEN_DIGITS; print_token(token_type, yytext); }
{fraction}    { token_type = TOKEN_FRACTION; print_token(token_type, yytext); }
{exponent}    { token_type = TOKEN_EXPONENT; print_token(token_type, yytext); }
{number}      { token_type = TOKEN_NUMBER; print_token(token_type, yytext); }

{rel_op_eq}   { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{rel_op_neq}  { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{rel_op_leq}  { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{rel_op_geq}  { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{rel_op_lt}   { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{rel_op_gt}   { token_type = TOKEN_RELATIONAL; print_token(token_type, yytext); }
{assignment}  { token_type = TOKEN_ASSIGNMENT; print_token(token_type, yytext); }
{whitesp}     ;


%%

int main(){
	printf("Enter the string: \n");
	yylex();
	
}

int yywrap() {
    return 1;
}

