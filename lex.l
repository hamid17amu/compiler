%{
#include<stdio.h>
#include"y.tab.h"

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
semicolon	(;)
whitesp		[ \t\n]


%%

int            { return INTEGER; }
bool           { return BOOLEAN; }
exit		{ return EXIT; }
{number}      	{ yylval.string = strdup(yytext); return NUMBER; }
{identifier}  	{ yylval.string = strdup(yytext); return IDENTIFIER; }
{rel_op_eq}   	{ yylval.string = strdup(yytext); return RELATIONAL; }
{rel_op_neq}  	{ yylval.string = strdup(yytext); return RELATIONAL; }
{rel_op_leq}  	{ yylval.string = strdup(yytext); return RELATIONAL; }
{rel_op_geq}  	{ yylval.string = strdup(yytext); return RELATIONAL; }
{rel_op_lt}   	{ yylval.string = strdup(yytext); return RELATIONAL; }
{rel_op_gt}   	{ yylval.string = strdup(yytext); return RELATIONAL; }
{assignment}  	{ return ASSIGNMENT; }
{semicolon}	{ return SEMICOLON;}
[-+()/*] 	{ return *yytext; }
{whitesp}     ;

%%

int yywrap() {
    return 1;
}

