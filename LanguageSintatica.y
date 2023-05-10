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
}TIPO_SIMBOLO;

vector<TIPO_SIMBOLO> tabelaSimbolos;
int yylex(void);
string GerarRegistrador();
TIPO_SIMBOLO verificaDeclaracao(string nome);
TIPO_SIMBOLO verificaExistencia(string nome);
void yyerror(string);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR TK_IGUAL

%start S

%left '+' '-'
%left '*' '/'

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

COMANDO 	:
			 /* E ';' */
			/* | */
			 TK_TIPO_INT TK_ID ';'{
				TIPO_SIMBOLO valor=verificaExistencia($2.label);
				valor.nomeVariavel=$2.label;
				valor.tipoVariavel="int";
				tabelaSimbolos.push_back(valor);
				$$.traducao="\t"+valor.tipoVariavel+" "+$2.label+";\n";
				$$.label="";
			}
			|TK_TIPO_INT TK_ID TK_IGUAL E ';'{
				TIPO_SIMBOLO variavel=verificaExistencia($2.label);
				$$.tipo=variavel.tipoVariavel;
				$$.traducao="\tint "+$2.label+";\n"+$2.traducao+$4.traducao+"\t"+$2.label+"="+$4.label+";\n";
			}
			|TK_ID TK_IGUAL E ';'{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.traducao=$1.traducao+$3.traducao+"\t"+$1.label+"="+$3.label+";\n";
			}
			;

E 			: E '+' E
			{
				$$.label=GerarRegistrador();
				$$.traducao = "\tint "+$1.label+";\n"+ "\tint "+$3.label+";\n"+"\tint "+$$.label+";\n"+
				$1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" + "+$3.label+" ;\n";
			}
			|E '*' E
			{
				$$.label=GerarRegistrador();
				$$.traducao ="\tint "+$1.label+";\n"+ "\tint "+$3.label+";\n"+"\tint "+$$.label+";\n"+ $1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" * "+$3.label+" ;\n";
			}
			|E '-' E
			{
				$$.label=GerarRegistrador();
				$$.traducao = "\tint "+$1.label+";\n"+ "\tint "+$3.label+";\n"+"\tint "+$$.label+";\n"+$1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" - "+$3.label+" ;\n";
			}
			|E '/' E
			{
				$$.label=GerarRegistrador();
				$$.traducao = "\tint "+$1.label+";\n"+ "\tint "+$3.label+";\n"+"\tint "+$$.label+";\n"+$1.traducao + $3.traducao +
				 "\t"+$$.label+" = "+$1.label+" / "+$3.label+" ;\n";
			}
			| TK_NUM
			{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			| TK_ID{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
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
			if(tabelaSimbolos[i].nomeVariavel.compare(nome)==0){
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
			if(tabelaSimbolos[i].nomeVariavel.compare(nome)==0){
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

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
