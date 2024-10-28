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
"while"		{ return WHILE;}
"|"		{ return OR;}
"&"		{ return AND;}
"!"		{ return NOT;} 		
"exit"		{ return EXIT; }
"=="          	{ yylval.string = strdup(yytext); return RELOP; }
"!="          	{ yylval.string = strdup(yytext); return RELOP; }
"<"           	{ yylval.string = strdup(yytext); return RELOP; }
">"           	{ yylval.string = strdup(yytext); return RELOP; }
"<="          	{ yylval.string = strdup(yytext); return RELOP; }
">="          	{ yylval.string = strdup(yytext); return RELOP; }


{number}      	{ yylval.string = strdup(yytext); return NUMBER; }
{identifier}  	{ yylval.string = strdup(yytext); return IDENTIFIER; }
{assignment}  	{ return ASSIGNMENT; }
{semicolon}	{ return SEMICOLON;}
[-+()/*] 	{ return *yytext; }
{whitesp}     	;

%%

int yywrap() {
    return 1;
}

