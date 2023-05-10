%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#define YYSTYPE atributos

using namespace std;
char registrador='`';
struct atributos
{
	string label;
	string traducao;
	string tipo;
};
typedef struct {
	string nomeVariavel;
	string tipoVariavel;
}TIPO_SIMBOLO;

vector<TIPO_SIMBOLO> tabelaSimbolos;
int yylex(void);
string GerarRegistrador();
void yyerror(string);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR TK_IGUAL

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS{
				$$.traducao=$1.traducao+$2.traducao;
			}
			|{
				$$.traducao="";
			}
			;

COMANDO 	: E ';'
			| TK_TIPO_INT TK_ID ';'{
				TIPO_SIMBOLO valor;
				valor.nomeVariavel=$2.label;
				valor.tipoVariavel="int";
				tabelaSimbolos.push_back(valor);
				$$.traducao="";
				$$.label="";
			}
			;

E 			: E '+' E
			{
				$$.label=GerarRegistrador();
				$$.traducao = $1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" + "+$3.label+" ;\n";
			}
			|TK_ID TK_IGUAL E{
				bool encontrei=false;
				TIPO_SIMBOLO variavel;
				for(int i=0;i<tabelaSimbolos.size();i++){
					if(tabelaSimbolos[i].nomeVariavel.compare($1.label)==0){
						variavel=tabelaSimbolos[i];
						encontrei=true;
					}
				}if(!encontrei){
					yyerror("Você não declarou a varivel");
				}
				$$.traducao=$1.traducao+$3.traducao+"\t"+$1.label+"="+$3.label+";\n";
			}
			|TK_TIPO_INT TK_ID TK_IGUAL E{
				bool encontrei=false;
				TIPO_SIMBOLO variavel;
				for(int i=0;i<tabelaSimbolos.size();i++){
					if(tabelaSimbolos[i].nomeVariavel.compare($2.label)==0){
						variavel=tabelaSimbolos[i];
						encontrei=true;
					}
				}if(encontrei){
					yyerror("Já existe uma varivel com esse nome ");
				}
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
				$$.traducao = "\t"+ $$.label+" = " + $2.label + ";\n";
				$$.traducao=$2.traducao+$4.traducao+"\t"+$2.label+"="+$4.label+";\n";
			}
			| TK_NUM
			{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				$$.traducao = "\t"+ $$.label+" = " + $1.label + ";\n";
			}
			| TK_ID{
				bool encontrei=false;
				TIPO_SIMBOLO variavel;
				for(int i=0;i<tabelaSimbolos.size();i++){
					if(tabelaSimbolos[i].nomeVariavel.compare($1.label)==0){
						variavel=tabelaSimbolos[i];
						encontrei=true;
					}
				}
				if(!encontrei){
					yyerror("Você não declarou a varivel");
				}
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
				$$.traducao = "\t"+ $$.label+" = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();
int main( int argc, char* argv[] )
{
	
	yyparse();

	return 0;
}

string GerarRegistrador(){
	registrador=registrador+1;
	string s(1,registrador);
	return s;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
