%{
#include<stdio.h>
%}

digit		[0-9]
letter		[a-zA-Z]
identifier	{letter}({letter}|{digit})*
digits 		{digit}+
fraction 	(\.{digits})?
exponent	(E[+-]?{digits})?
number		{digits}{fraction}{exponent}
whitesp		[ \t\n]

%%

{digit} 	{printf("%s is a digit\n", yytext);}
{letter} 	{printf("%s is a letter\n", yytext);}
{identifier} 	{printf("%s is a identifier\n", yytext);}
{digits} 	{printf("%s is a digits\n", yytext);}
{fraction} 	{printf("%s is a fraction\n", yytext);}
{exponent} 	{printf("%s is a exponent\n", yytext);}
{number} 	{printf("%s is a number\n", yytext);}
{whitesp} 	;

%%

int main(){
	printf("Enter the string: \n");
	yylex();
	
}

int yywrap() {
    return 1;
}

