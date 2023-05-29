%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#define YYSTYPE atributos

using namespace std;
int registrador=0;
typedef struct atributos
{
	string label;
	string traducao;
	string tipo;
}atributos;
typedef struct {
	string nomeVariavel;
	string tipoVariavel;
	bool temp;
	string nomeOriginal;
}TIPO_SIMBOLO;

vector<TIPO_SIMBOLO> tabelaSimbolos;
int yylex(void);
string GerarRegistrador();
atributos verificacaoTipos(atributos elemen1,string operador,atributos elemen2);
TIPO_SIMBOLO verificaDeclaracao(string nome);
TIPO_SIMBOLO verificaExistencia(string nome);
void insereTabela(string nome, string tipo,bool temp,string nomeFantasia);
void yyerror(string);
%}

%token TK_NUM TK_REAL TK_STRING
%token TK_MAIOR_IGUAL TK_MENOR_IGUAL TK_IGUALDADE TK_IDENTICO TK_DIFERENTE;
%token TK_MAIN TK_ID TK_INT TK_FLOAT TK_FRASE TK_BOOL
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
			|TK_BOOL{
				$$.tipo="bool";
			}
COMANDO 	:
			 /* E ';' */
			/* | */
			 TK_TIPO TK_ID ';'{
				verificaExistencia($2.label);
				string nomeFantasia=$2.label;
				$2.label=GerarRegistrador();
				insereTabela($2.label,$1.tipo,false,nomeFantasia);
				// valor.nomeVariavel=$2.label;
				// valor.tipoVariavel=$1.tipo;
				// valor.temp=false;
				// tabelaSimbolos.push_back(valor);
				$$.traducao="";
				$$.label="";
			}
			|TK_TIPO TK_ID TK_IGUAL OPERATIONS';'{
				verificaExistencia($2.label);
				string nomeFantasia=$2.label;
				$2.label=GerarRegistrador();
				insereTabela($2.label,$1.tipo,false,nomeFantasia);
				$2.tipo=$1.tipo;
				atributos elemento=verificacaoTipos($2,"=",$4);
				if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao=elemento.traducao+"\t"+$2.label+"="+$4.label+";\n";
			}
			|TK_ID TK_IGUAL OPERATIONS';'{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$1.label=variavel.nomeVariavel;
				$1.tipo=variavel.tipoVariavel;
				atributos elemento=verificacaoTipos($1,"=",$3);
				if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao=elemento.traducao+"\t"+$1.label+"="+$3.label+";\n";
			}
			|RELACION';'{
				
			}
OPERATIONS: RELACION 
			|CALC
OPRELACION: '>'{
				$$.label=">";
			}
			|'<'{
				$$.label="<";
			}
			|TK_MAIOR_IGUAL{
				$$.label=">=";
			}
			|TK_MENOR_IGUAL{
				$$.label="<=";
			}
			|TK_IGUALDADE{
				$$.label="==";
			}
			|TK_IDENTICO{
				$$.label="===";
			}
			|TK_DIFERENTE{
				$$.label="!=";
			}
			
RELACION:      CALC OPRELACION CALC{
				
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
			}
			|'('RELACION')'{
				$$.tipo=$2.tipo;
				$$.label=$2.label;
				$$.traducao=$2.traducao;
			}
			
CALC			: CALC'+'CALC
			{
				atributos elemento=verificacaoTipos($1,"+",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" + "+$3.label+" ;\n";
			}
			|CALC'*'CALC
			{
				cout<<$1.label +" "+$2.label<<endl;
				atributos elemento=verificacaoTipos($1,"*",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" * "+$3.label+" ;\n";
			}
			|CALC'-'CALC
			{   
				atributos elemento=verificacaoTipos($1,"-",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao =elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" - "+$3.label+" ;\n";
			}
			|CALC'/'CALC
			{
				atributos elemento=verificacaoTipos($1,"/",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao =elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" / "+$3.label+" ;\n";
			}|'('CALC')'{
				$$.tipo=$2.tipo;
				$$.label=$2.label;
				$$.traducao=$2.traducao;
			}
			|CONVERSION
CONVERSION:    ELEMENTS{}
			|'('TK_TIPO')'ELEMENTS{
				$4.tipo=$2.tipo;
				$$.tipo=$2.tipo;
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao=$4.traducao+"\t"+$$.label+"=("+$2.tipo+")"+$4.label+";\n";
			}
ELEMENTS:        TK_NUM
			{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			|  '-'TK_NUM
			{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " +"-" +$2.label + ";\n";
			}
			|TK_REAL{
				$$.tipo="float";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			| TK_ID{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}|TK_FRASE{
				$$.tipo="string";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
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
 atributos verificacaoTipos(atributos elemen1,string operador ,atributos elemen2){
	if(elemen1.tipo==elemen2.tipo){
		atributos elemento;
		elemento.tipo=elemen1.tipo;
		elemento.label="";	
		elemento.traducao=elemen1.traducao+elemen2.traducao;
		return elemento;
	} else if(elemen1.tipo=="float" && elemen2.tipo=="int"){
		atributos elemento;
		elemento.tipo="float";
		elemento.label=GerarRegistrador();
		elemento.traducao=elemen1.traducao+elemen2.traducao+"\t"+elemento.label+"= ("+elemento.tipo+")"+elemen2.label+";\n";
		insereTabela(elemento.label,elemento.tipo,true,"");
		return elemento;
		
	}else if(operador!="="&&(elemen1.tipo=="int" && elemen2.tipo=="float")){
		atributos elemento;
		elemento.tipo="float";
		elemento.label=GerarRegistrador();
		elemento.traducao=elemen1.traducao+elemen2.traducao+"\t"+elemento.label+"= ("+elemento.tipo+")"+elemen1.label+";\n";
		insereTabela(elemento.label,elemento.tipo,true,"");
		return elemento;
		
	}else{
		cout<<elemen1.tipo +" "+elemen2.tipo<<endl;
		yyerror("Tipagem errada");
	}
	atributos atributo;
	return atributo;
} 
TIPO_SIMBOLO verificaExistencia(string nome){
		bool encontrei=false;
		TIPO_SIMBOLO valor;
		for(int i=0;i<tabelaSimbolos.size();i++){
			if(!tabelaSimbolos[i].temp&&(tabelaSimbolos[i].nomeOriginal.compare(nome)==0)){
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
			if(!tabelaSimbolos[i].temp&&(tabelaSimbolos[i].nomeOriginal.compare(nome)==0)){
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
void insereTabela(string nome, string tipo,bool b,string nomeFantasia){
		TIPO_SIMBOLO temp;
		temp.tipoVariavel=tipo;
		temp.nomeVariavel=nome;
		temp.temp=b;
		temp.nomeOriginal=nomeFantasia;
		tabelaSimbolos.push_back(temp);
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
