%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
ASPAS2 \"

DELIM {ESPACO}+
NUM {DIGITO}+
INT {NUM}
REAL {INT}+("."{NUM}+)
CHAR \'({LETRA}|{NUM})\'
STRING{ASPAS2}(({LETRA}|{NUM}|{ESPACO}|[(){}[\];,]|[+\-*/=%$#@!&¨*<>,.;|^~`´?]|[éÉçÇãÃáÁÀàÊêõÕôôÔÓóÒòÚú])+)?{ASPAS2}
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"if"        {return TK_IF;}
"else"      {return TK_ELSE;}
"for"       {return TK_FOR;}
"while"     { return TK_WHILE;}
"do"        {return TK_DO;}
"continue"  {return TK_CONTINUE;}
"break"     {return TK_BREAK;}

"int"		{return TK_INT;}
"float"     {return TK_FLOAT;}
"string"     {return TK_STRING;}
"char"      {return TK_CHAR;}
"bool"     {return TK_BOOL;}
"var"       {return TK_VAR;}

"scanner"   {return TK_SCANNER;}
"print"     {return TK_PRINT;}
"return"      {return TK_RETURN;}
[(){}[\];,]	{ return *yytext; }
(<|>)	{ return *yytext; }
[+\-*/]		{ return *yytext; }
"="         {return TK_IGUAL;}
">="    {return TK_MAIOR_IGUAL;}
"<="    {return TK_MENOR_IGUAL;}
"=="        {return TK_IGUALDADE;}
"==="       {return TK_IDENTICO;}
"!="        {return TK_DIFERENTE;}
"||"        {return TK_OU;}
"&&"        {return TK_E;}
"!"         {return TK_NEGACAO;}


{INT}		{ yylval.label = yytext; return TK_NUM; }
{REAL}      { yylval.label = yytext; return TK_REAL;}
{CHAR}      { yylval.label = yytext; return TK_CHARACTER;}
{STRING}      { yylval.label = yytext; return TK_FRASE;}
"true"      {yylval.label = yytext;return TK_TRUE;}
"false"     {yylval.label = yytext;return TK_FALSE;}
{ID}		{ yylval.label = yytext; return TK_ID; }



.			{ *yytext; }

%%
