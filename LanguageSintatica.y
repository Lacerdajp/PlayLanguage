%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#define YYSTYPE atributos

using namespace std;
int registrador=0;
struct atributos
{
	string label;
	string traducao;
	string tipo;
};
typedef struct {
	string nomeVariavel;
	string tipoVariavel;
	bool temp;
}TIPO_SIMBOLO;

vector<TIPO_SIMBOLO> tabelaSimbolos;
int yylex(void);
string GerarRegistrador();
TIPO_SIMBOLO verificaDeclaracao(string nome);
TIPO_SIMBOLO verificaExistencia(string nome);
void insereTabela(string nome, string tipo,bool temp);
void yyerror(string);
%}

%token TK_NUM TK_REAL TK_STRING
%token TK_MAIN TK_ID TK_INT TK_FLOAT TK_FRASE
%token TK_FIM TK_ERROR TK_IGUAL

%start S

%left '+' '-'
%left '*' '/'
%%

S 			: TK_TIPO TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador Play Language*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				string declaracoes="";
				for(TIPO_SIMBOLO atual: tabelaSimbolos){
					declaracoes="\t"+atual.tipoVariavel+" "+atual.nomeVariavel+";\n"+declaracoes;
				}
				$$.traducao = declaracoes+$2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS{
				$$.traducao=$1.traducao+$2.traducao;
			}
			|{
				$$.traducao="";
			}
			;
TK_TIPO:    TK_INT{
				$$.tipo="int";
			}
			| TK_FLOAT{
				$$.tipo="float";
			}
			|TK_STRING{
				$$.tipo="string";
			}
COMANDO 	:
			 /* E ';' */
			/* | */
			 TK_TIPO TK_ID ';'{
				verificaExistencia($2.label);
				insereTabela($2.label,$1.tipo,false);
				// valor.nomeVariavel=$2.label;
				// valor.tipoVariavel=$1.tipo;
				// valor.temp=false;
				// tabelaSimbolos.push_back(valor);
				$$.traducao="";
				$$.label="";
			}
			|TK_TIPO TK_ID TK_IGUAL CALC ';'{
				verificaExistencia($2.label);
				insereTabela($2.label,$1.tipo,false);
				$$.traducao=$2.traducao+$4.traducao+"\t"+$2.label+"="+$4.label+";\n";
			}
			|TK_ID TK_IGUAL CALC ';'{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.traducao=$1.traducao+$3.traducao+"\t"+$1.label+"="+$3.label+";\n";
			}
			;
CALC			: CALC'+' CALC
			{
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao = $1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" + "+$3.label+" ;\n";
			}
			|CALC '*' CALC
			{
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao = $1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" * "+$3.label+" ;\n";
			}
			|CALC '-' CALC
			{
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao =$1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" - "+$3.label+" ;\n";
			}
			|CALC '/' CALC
			{

				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao =$1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" / "+$3.label+" ;\n";
			}
			|ELEMENTS{}
ELEMENTS:        TK_NUM
			{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			|TK_REAL{
				$$.tipo="float";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			| TK_ID{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}|TK_FRASE{
				$$.tipo="string";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true);
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
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
TIPO_SIMBOLO verificaExistencia(string nome){
		bool encontrei=false;
		TIPO_SIMBOLO valor;
		for(int i=0;i<tabelaSimbolos.size();i++){
			if(!tabelaSimbolos[i].temp&&(tabelaSimbolos[i].nomeVariavel.compare(nome)==0)){
				valor=tabelaSimbolos[i];
				encontrei=true;
			}
			}
		if(encontrei){
			yyerror("Já existe uma varivel com esse nome ");
		}
		return valor;
}	
TIPO_SIMBOLO verificaDeclaracao(string nome){
		bool encontrei=false;
		TIPO_SIMBOLO variavel;
		for(int i=0;i<tabelaSimbolos.size();i++){
			if(!tabelaSimbolos[i].temp&&(tabelaSimbolos[i].nomeVariavel.compare(nome)==0)){
				variavel=tabelaSimbolos[i];
				encontrei=true;
						
			}
		}
		if(!encontrei){
			yyerror("Você não declarou a varivel 1");
		}
		return variavel;
}
string GerarRegistrador(){
	registrador=registrador+1;
	/* string s(1,registrador); */
	string s="temp"+std::to_string(registrador);
	return s;
}
void insereTabela(string nome, string tipo,bool b){
		TIPO_SIMBOLO temp;
		temp.tipoVariavel=tipo;
		temp.nomeVariavel=nome;
		temp.temp=b;
		tabelaSimbolos.push_back(temp);
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
