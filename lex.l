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

"int"           { return INTEGER; }
"bool"          { return BOOLEAN; }
"true"		{ return TRUE; }
"false"		{ return FALSE; }
"if"		{ return IF; }
"else"		{ return ELSE;}
"|"		{ return OR;}
"&"		{ return AND;}
"!"		{ return NOT;} 		
"exit"		{ return EXIT; }
"=="          	{ return EQ; }
"!="          	{ return NE; }
"<"           	{ return LS; }
">"           	{ return GR; }
"<="          	{ return LE; }
">="          	{ return GE; }


{number}      	{ yylval.string = strdup(yytext); return NUMBER; }
{identifier}  	{ yylval.string = strdup(yytext); return IDENTIFIER; }
{assignment}  	{ return ASSIGNMENT; }
{semicolon}	{ return SEMICOLON;}
[-+()/*] 	{ return *yytext; }
{whitesp}     ;

%%

int yywrap() {
    return 1;
}

