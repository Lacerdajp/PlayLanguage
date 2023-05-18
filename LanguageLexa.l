%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
INT ([-])?{NUM}
REAL {INT}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
STRING\'({LETRA}|{NUM}|{ESPACO}|[(){}[\];,]|[+\-*/=%$#@!&¨*<>,.;|^~`´?])+\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_INT;}
"float"     {return TK_FLOAT;}
"string"     {return TK_STRING;}
[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }
"="         {return TK_IGUAL;}
{INT}		{ yylval.label = yytext; return TK_NUM; }
{REAL}      { yylval.label = yytext; return TK_REAL;}
{STRING}      { yylval.label = yytext; return TK_FRASE;}
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
