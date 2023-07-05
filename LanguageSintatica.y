//IMPLEMENTE O TIPO BOOL

%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#define YYSTYPE atributos

using namespace std;
int registrador=0;
int ifs=0;
int elses=0;
int loops=0;
int loopsAtivos=0;
typedef struct atributos{
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
typedef struct {
	string nome;
	string tipo;
	
}DECLARACAO;
vector<DECLARACAO> declaracoes;
vector<TIPO_SIMBOLO> tabelaSimbolos;
vector<vector<TIPO_SIMBOLO>> pilhaTabela;
int yylex(void);
string GerarRegistrador();
string imprimirDeclaracaoVariavel();
void insereDeclaracoes(vector<TIPO_SIMBOLO> tabela );
atributos verificacaoTipos(atributos elemen1,string operador,atributos elemen2);
TIPO_SIMBOLO verificaDeclaracao(string nome);
TIPO_SIMBOLO verificaExistencia(string nome);
void inserirPilha(vector<TIPO_SIMBOLO> tabela);
void removerPilha();
void alterarTabela(string nome,string tipo);
void zerarTabela();
atributos calcAtribuicao(atributos elemen1,string operador,atributos elemen2);
void insereTabela(string nome, string tipo,bool temp,string nomeFantasia);
void yyerror(string);
%}

%token TK_NUM TK_REAL TK_STRING TK_CHARACTER
%token TK_MAIOR_IGUAL TK_MENOR_IGUAL TK_IGUALDADE TK_IDENTICO TK_DIFERENTE
%token TK_MAIN TK_ID TK_INT TK_FLOAT TK_FRASE TK_BOOL TK_TRUE TK_FALSE TK_CHAR
%token TK_OU  TK_E  TK_NEGACAO TK_VAR
%token TK_IF  TK_ELSE   TK_FOR TK_WHILE TK_DO TK_CONTINUE TK_BREAK
%token TK_FIM TK_ERROR TK_IGUAL

%start S

%left TK_E TK_OU TK_NEGACAO
%left '+' '-'
%left '*' '/'

%%
//Tokens que só servem para ativar algo
TOKEN_WHILE: 
			TK_WHILE{
				loopsAtivos++;	
			}
TOKEN_DO: 
		TK_DO{
			loopsAtivos++;	
		}
TOKEN_FOR:  
		TK_FOR{
			//cout<<"test"<<endl;
			loopsAtivos++;
			}
CHAVE_ENTRADA	: '{'{
				
				inserirPilha(tabelaSimbolos);
						// vector<TIPO_SIMBOLO>tabela=pilhaTabela.back();
				//  insereDeclaracoes(tabela);
				zerarTabela();
				}
CHAVE_SAIDA	: '}'{
				// vector<TIPO_SIMBOLO>tabela=pilhaTabela.back();
				//  insereDeclaracoes(tabela);
				zerarTabela();
				 tabelaSimbolos=pilhaTabela.back();
				 removerPilha();
				 
				}

OPATRIBUICAO: 	
		'+'TK_IGUAL{
			$$.label="+=";
		}
		| '-'TK_IGUAL{
			$$.label="-=";
		}
		| '*'TK_IGUAL{
			$$.label="*=";
		}
		| '/'TK_IGUAL{
			$$.label="/=";
		}
//ramo principal
S 			: 
			TK_TIPO TK_MAIN '(' ')'  BLOCO_FUNCTION{
				cout << "/*Compilador Play Language*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << imprimirDeclaracaoVariavel()+ $5.traducao << "\treturn 0;\n}" << endl; 
			}| INIT{
				cout << "/*Compilador Play Language*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << imprimirDeclaracaoVariavel()+ $1.traducao << "\treturn 0;\n}" << endl; 
			}
			;

//decide se vai ter Bloco ou só comandos
INIT: 		
			BLOCO	{
				$$.traducao = $1.traducao;
			}|
			COMANDOS{
				$$.traducao = $1.traducao;
			}
BLOCO_FUNCTION: 	
			CHAVE_ENTRADA INIT CHAVE_SAIDA{
				// cout<<3<<endl;
				$$.traducao = $2.traducao;
			}
			
BLOCO		:  
			COMANDOS BLOCO COMANDOS{
				// cout<<2<<endl;
				$$.traducao=$1.traducao+ $2.traducao+$3.traducao;
			}|
			BLOCO_FUNCTION{
				// cout<<3<<endl;
				$$.traducao = $1.traducao;
			}
			|BLOCO BLOCO{
				// cout<<4<<endl;
				$$.traducao=$1.traducao+ $2.traducao;
			}
			;

COMANDOS	: 
			COMANDO COMANDOS{
				// cout<< "X :"+ pilhaTabela.size()<<endl;
				 insereDeclaracoes(tabelaSimbolos);
				$$.traducao=$1.traducao+$2.traducao;	
				
			}
			|{
				// cout<<1 <<endl;
				$$.traducao="";
			}
			;
IF:			
			TK_IF '('LOGIC')' COMANDBLOCO{
				ifs++;		
				atributos elemento=verificacaoTipos($3,"!",$3);
				 string label=GerarRegistrador();
				 string tipo="bool";
				insereTabela(label,tipo,true,"");
				$$.traducao=$3.traducao+ "\t"+label+" = !"+$3.label+" ;\n"+
				"\tIF("+label+") Goto FIM_IF"+to_string(ifs)+";\n"+
				$5.traducao+"\tFIM_IF"+to_string(ifs)+":\n";
			}
			| TK_IF '('LOGIC')' COMANDBLOCO TK_ELSE COMANDBLOCO{
				ifs++;	
				elses++;	
				atributos elemento=verificacaoTipos($3,"!",$3);
				 string label=GerarRegistrador();
				 string tipo="bool";
				insereTabela(label,tipo,true,"");
				$$.traducao=$3.traducao+ "\t"+label+" = !"+$3.label+" ;\n"+
				"\tIF("+label+") Goto ELSE"+to_string(elses)+";\n"+
				$5.traducao+"\tGoto FIM_IF"+to_string(ifs)+ 
				"\n\tELSE"+to_string(elses)+":\n"+$7.traducao+"\tFIM_IF"+to_string(ifs)+":\n";
			}

LOOPS: 		
		 TOKEN_WHILE'('LOGIC')' COMANDBLOCO{	
				loops++;
				verificacaoTipos($3,"!",$3);
				 string label=GerarRegistrador();
				 string tipo="bool";
				insereTabela(label,tipo,true,"");
				$$.traducao= "\tINICIO_WHILE"+to_string(loops)+":\n"+$3.traducao+"\t"+label+" = !"+$3.label+" ;\n"+
				"\tIF("+label+") Goto FIM_WHILE"+to_string(loops)+";\n"+
				$5.traducao+"\tGoto INICIO_WHILE"+to_string(loops)+"\n\tFIM_WHILE"+to_string(loops)+":\n";
				loopsAtivos--;
		}
		| 	TOKEN_DO COMANDBLOCO	TK_WHILE'('LOGIC')'';'{	
				loops++;
				verificacaoTipos($5,"!",$5);
				 string label=GerarRegistrador();
				 string tipo="bool";
				insereTabela(label,tipo,true,"");
				$$.traducao= "\tINICIO_WHILE"+to_string(loops)+":\n"+$2.traducao+$5.traducao+"\t"+label+" = !"+$5.label+" ;\n"+
				"\tIF("+label+") Goto FIM_WHILE"+to_string(loops)+";\n"+"\tGoto INICIO_WHILE"+to_string(loops)+"\n\tFIM_WHILE"+to_string(loops)+":\n";
				loopsAtivos--;
		}
		| TOKEN_FOR '('EXPRESSAO ';' LOGIC';' EXPRESSAO')'COMANDBLOCO{
				loops++;
				verificacaoTipos($5,"!",$5);
				 string label=GerarRegistrador();
				 string tipo="bool";
				insereTabela(label,tipo,true,"");
				$$.traducao= $3.traducao+"\tINICIO_WHILE"+to_string(loops)+":\n"+$5.traducao+"\t"+label+" = !"+$5.label+" ;\n"+
				"\tIF("+label+") Goto FIM_WHILE"+to_string(loops)+";\n"+$9.traducao+$7.traducao+"\tGoto INICIO_WHILE"+to_string(loops)+"\n\tFIM_WHILE"+to_string(loops)+":\n";
				loopsAtivos--;
		}
COMANDBLOCO :
			BLOCO_FUNCTION{
				$$.traducao=$1.traducao;
			}			
			| COMANDO{
				$$.traducao=$1.traducao;
			}
TK_TIPO:    
			TK_INT{
				$$.tipo="int";
			}
			| TK_FLOAT{
				$$.tipo="float";
			}
			|TK_CHAR{
				$$.tipo="char";
			}
			|TK_STRING{
				$$.tipo="string";
			}
			|TK_BOOL{
				$$.tipo="bool";

			}|TK_VAR{
				$$.tipo="var";
			}
EXPRESSAO 	:
			 /* E ';' */
			/* | */
			 TK_TIPO TK_ID {
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
				//cout<<"teste"<<endl;
			}
			|TK_TIPO TK_ID TK_IGUAL ATRIBOPERATION{
				
				verificaExistencia($2.label);
				string nomeFantasia=$2.label;
				$2.label=GerarRegistrador();
				insereTabela($2.label,$1.tipo,false,nomeFantasia);
				$2.tipo=$1.tipo;
				atributos elemento=verificacaoTipos($2,"=",$4);
				if($4.tipo=="int" && $1.tipo=="float") $4=elemento;
				$$.traducao=elemento.traducao+"\t"+$2.label+"="+$4.label+";\n";
				//cout<<$$.traducao<<endl;
			}
			|ATRIBUICAO{
				$$.traducao=$1.traducao;
			}
			|LOGIC{
			}

ATRIBUICAO:  	
			TK_ID TK_IGUAL ATRIBOPERATION{
				
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$1.label=variavel.nomeVariavel;
				$1.tipo=variavel.tipoVariavel;
				atributos elemento=verificacaoTipos($1,"=",$3);
				if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				 $$.label=$1.label;
				 $$.tipo=$1.tipo;
				$$.traducao=elemento.traducao+"\t"+$1.label+"="+$3.label+";\n";
				// cout<<$$.label<<endl;
				
			}
			|TK_ID OPATRIBUICAO ATRIBOPERATION{
				$$=calcAtribuicao($1,$2.label,$3);
				// cout<<$$.label<<endl;	
			}
			| TK_ID '+''+'{
				
				$$=calcAtribuicao($1,"++",$1);
			}| 
			TK_ID '-''-'{
				$$=calcAtribuicao($1,"--",$1);
			}
ATRIBOPERATION: 	
				ATRIBUICAO{
						
						$$.traducao=$1.traducao;
						// cout<<$$.traducao<<endl;
				}
				| OPERATIONS{
						$$.traducao=$1.traducao;
						//cout<<$$.traducao<<endl;
				}
COMANDOLOOPS:  
		TK_BREAK{
			if(loopsAtivos==0){
				 yyerror("BREAK SEM LOOP");
			}else{
				$$.traducao="\t Goto FIM_WHILE"+to_string(loops+1)+";\n";
			}
		}
		|TK_CONTINUE{
			if(loopsAtivos==0){
				 yyerror("CONTINUE SEM LOOP");
			}else{
				$$.traducao="\t Goto INICIO_WHILE"+to_string(loops+1)+";\n";
			}
		}
COMANDO:	
		EXPRESSAO';'{
				$$.traducao=$1.traducao;
				//cout<<$$.traducao<<endl;
			}
			|IF  {
				$$.traducao=$1.traducao;
			}
			|LOOPS{
				$$.traducao=$1.traducao;
			}
			| COMANDOLOOPS ';'{
				$$.traducao=$1.traducao;
			}
OPERATIONS: 
			LOGIC
			|CALC{
			}
OPLOGIC: 
		TK_OU{
			$$.label="||";
		}
		| TK_E{
			$$.label="&&";
		}
LOGIC:		
			LOGIC OPLOGIC  LOGIC{
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
			}
			|CALC OPLOGIC  CALC{
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
			}
			|LOGIC OPLOGIC  CALC{
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
			}
			|CALC OPLOGIC  LOGIC{
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
			}
			|TK_NEGACAO LOGIC{
				atributos elemento=verificacaoTipos($2,"!",$2);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = !"+$2.label+" ;\n";
			}
			|TK_NEGACAO CALC{
				atributos elemento=verificacaoTipos($2,"!",$2);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = !"+$2.label+" ;\n";
			}
			|RELACION{
				$$.label=$1.label;
				$$.tipo=$1.tipo;
				$$.traducao=$$.traducao;
			}
			|'('LOGIC')'{
				$$.tipo=$2.tipo;
				$$.label=$2.label;
				$$.traducao=$2.traducao;
			}
OPRELACION: 
			'>'{
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

			
RELACION:      
			CALC OPRELACION CALC{
				
				atributos elemento=verificacaoTipos($1,$2.label,$3);
				$$.label=GerarRegistrador();
				$$.tipo="bool";
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" "+$2.label+" "+$3.label+" ;\n";
				// cout<<$$.traducao<<endl;
			}
					
CALC			:
			CALC'+'CALC{
				atributos elemento=verificacaoTipos($1,"+",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao+
				 "\t"+$$.label+" = "+$1.label+" + "+$3.label+" ;\n";
			}|
			CALC'*'CALC{
				atributos elemento=verificacaoTipos($1,"*",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao = elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" * "+$3.label+" ;\n";
			}
			|CALC'-'CALC{   
				atributos elemento=verificacaoTipos($1,"-",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao =elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" - "+$3.label+" ;\n";
			}
			|CALC'/'CALC{
				atributos elemento=verificacaoTipos($1,"/",$3);
				$$.label=GerarRegistrador();
				$$.tipo=elemento.tipo;
				insereTabela($$.label,$$.tipo,true,"");
				if ($1.tipo=="int"&&$3.tipo=="float") $1=elemento;
				else if($3.tipo=="int" && $1.tipo=="float") $3=elemento;
				$$.traducao =elemento.traducao +
				 "\t"+$$.label+" = "+$1.label+" / "+$3.label+" ;\n";
			}|
			'('CALC')'{
				$$.tipo=$2.tipo;
				$$.label=$2.label;
				$$.traducao=$2.traducao;
			}
			|CONVERSION
CONVERSION:    
			ELEMENTS{
			}
			|'('TK_TIPO')'ELEMENTS{
				$4.tipo=$2.tipo;
				$$.tipo=$2.tipo;
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao=$4.traducao+"\t"+$$.label+"=("+$2.tipo+")"+$4.label+";\n";
			}
ELEMENTS:        
			TK_NUM{
				$$.tipo="int";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			|  '-'TK_NUM{
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
			|TK_CHARACTER{
				$$.tipo="char";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			|TK_FRASE{
				$$.tipo="string";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + $1.label + ";\n";
			}
			|TK_TRUE{
				$$.tipo="bool";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + "1"+ ";\n";
			}
			|TK_FALSE{
				$$.tipo="bool";
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				$$.traducao ="\t"+ $$.label+" = " + "0"+ ";\n";
			}
			| TK_ID{
				TIPO_SIMBOLO variavel=verificaDeclaracao($1.label);
				$$.tipo=variavel.tipoVariavel;
				$$.label=GerarRegistrador();
				insereTabela($$.label,$$.tipo,true,"");
				
				$$.traducao ="\t"+ $$.label+" = " +variavel.nomeVariavel + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();
int main( int argc, char* argv[] ){
	
	yyparse();

	return 0;
}
string imprimirDeclaracaoVariavel(){
	string declaracao="";
	for(DECLARACAO atual: declaracoes){
					if(atual.tipo=="var"){
						continue;
					}
					if(atual.tipo=="bool"){
						declaracao="\tint "+atual.nome+";\n"+declaracao;
					}else{
						declaracao="\t"+atual.tipo+" "+atual.nome+";\n"+declaracao;
					}
					
				}
	return declaracao;
}
void insereDeclaracoes(vector<TIPO_SIMBOLO> tabela ){
	int flag=0;
	for(TIPO_SIMBOLO atual:tabela){
		DECLARACAO dec;
		dec.nome=atual.nomeVariavel;
		dec.tipo=atual.tipoVariavel;
		for(DECLARACAO i:declaracoes){
			if(dec.nome==i.nome)flag++;
		}
		if(flag==0) declaracoes.push_back(dec);
		else flag--;
	}
}
 atributos verificacaoTipos(atributos elemen1,string operador ,atributos elemen2){
	if((operador=="="&&elemen1.tipo==elemen2.tipo&&elemen1.tipo!="var")||
	(operador=="+"&&elemen1.tipo==elemen2.tipo&&(
	(elemen1.tipo=="string")||(elemen1.tipo=="int")||(elemen1.tipo=="float"))
	)||
	(((operador!="=")&&(operador!="+")&&(operador!="||")&&(operador!="&&")&&(operador!="!"))
	&&elemen1.tipo==elemen2.tipo&&(
	(elemen1.tipo=="int")||(elemen1.tipo=="float"))
	)||
	((operador=="=="||operador=="!="||operador=="===")&&elemen1.tipo==elemen2.tipo&&
	(elemen1.tipo=="string"||elemen1.tipo=="bool"||elemen1.tipo=="char"))||
	(((operador=="&&")||(operador=="||"))&&elemen1.tipo==elemen2.tipo&&(elemen1.tipo=="bool"))
	){
		atributos elemento;
		elemento.tipo=elemen1.tipo;
		elemento.label="";	
		elemento.traducao=elemen1.traducao+elemen2.traducao;
		return elemento;
	}else if((operador=="!")&&elemen1.tipo==elemen2.tipo&&(elemen1.tipo=="bool"))
	{
		atributos elemento;
		elemento.tipo=elemen1.tipo;
		elemento.label="";	
		elemento.traducao=elemen1.traducao;
		return elemento;
	} else if(((operador!="&&")&&(operador!="||")&&(operador!="!"))&&(elemen1.tipo=="float" && elemen2.tipo=="int")){
		atributos elemento;
		elemento.tipo="float";
		elemento.label=GerarRegistrador();
		elemento.traducao=elemen1.traducao+elemen2.traducao+"\t"+elemento.label+"= ("+elemento.tipo+")"+elemen2.label+";\n";
		insereTabela(elemento.label,elemento.tipo,true,"");
		return elemento;
		
	}else if((operador!="="&&(operador!="&&")&&(operador!="!")&&(operador!="||"))&&(elemen1.tipo=="int" && elemen2.tipo=="float")){
		atributos elemento;
		elemento.tipo="float";
		elemento.label=GerarRegistrador();
		elemento.traducao=elemen1.traducao+elemen2.traducao+"\t"+elemento.label+"= ("+elemento.tipo+")"+elemen1.label+";\n";
		insereTabela(elemento.label,elemento.tipo,true,"");
		return elemento;
		
	}else if(operador=="="&&(elemen1.tipo=="var"&&elemen2.tipo!="var")){
		alterarTabela(elemen1.label,elemen2.tipo);
		atributos elemento;
		elemento.tipo=elemen2.tipo;
		elemento.label="";	
		elemento.traducao=elemen1.traducao+elemen2.traducao;
		return elemento;
	}
	else if((operador!="="&&(elemen1.tipo=="var"&&elemen2.tipo!="var"))
	||(operador=="="&&(elemen1.tipo!="var"&&elemen2.tipo=="var"))
	||(operador!="="&&(elemen1.tipo!="var"&&elemen2.tipo=="var"))
	||(elemen1.tipo=="var"&&elemen2.tipo=="var")
	){
		yyerror("Você nao atribuiu nenhum tipo ao operador var");
	}
	else{
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
			if(!tabelaSimbolos.at(i).temp&&(tabelaSimbolos.at(i).nomeOriginal.compare(nome)==0)){
				variavel=tabelaSimbolos.at(i);
				encontrei=true;
				break;	
			}
		}
		if(encontrei){
			return variavel;
		}
		
		for(int j=pilhaTabela.size()-1;j>=0;j--){
			for(int i=0;i<pilhaTabela.at(j).size();i++){
				
				if(!pilhaTabela.at(j).at(i).temp&&(pilhaTabela.at(j).at(i).nomeOriginal.compare(nome)==0)){
						
					variavel=pilhaTabela.at(j).at(i);
					encontrei=true;
					break;		
				}
				
			}
			if(encontrei){
				break;
			}
		}
		if(!encontrei){
			cout<<nome<<endl;
			yyerror("Você não declarou a varivel");
		}
		return variavel;
}
string GerarRegistrador(){
	registrador=registrador+1;
	/* string s(1,registrador); */
	string s="temp"+std::to_string(registrador);
	return s;
}
void inserirPilha(vector<TIPO_SIMBOLO> tabela){
	pilhaTabela.push_back(tabela);
}
void removerPilha(){
	
	pilhaTabela.pop_back();
	
}
void alterarTabela(string nome,string tipo){
	TIPO_SIMBOLO variavel;
		for(int i=0;i<tabelaSimbolos.size();i++){
			if(!tabelaSimbolos[i].temp&&(tabelaSimbolos[i].nomeVariavel.compare(nome)==0)){
				tabelaSimbolos[i].tipoVariavel=tipo;
			}
		}
}
void insereTabela(string nome, string tipo,bool b,string nomeFantasia){
		TIPO_SIMBOLO temp;
		temp.tipoVariavel=tipo;
		temp.nomeVariavel=nome;
		temp.temp=b;
		temp.nomeOriginal=nomeFantasia;
		tabelaSimbolos.push_back(temp);
}
void zerarTabela(){
	for(TIPO_SIMBOLO temp : tabelaSimbolos){
		tabelaSimbolos.pop_back();
	}
}
atributos calcAtribuicao(atributos elemen1,string operador,atributos elemen2){
	if(operador.substr(1)=="="){
	TIPO_SIMBOLO variavel=verificaDeclaracao(elemen1.label);
		elemen1.label=variavel.nomeVariavel;
		elemen1.tipo=variavel.tipoVariavel;
		atributos temp;
		temp.label=GerarRegistrador();
		temp.tipo=elemen1.tipo;
		insereTabela(temp.label,temp.tipo,true,"");
		temp.traducao="\t"+ temp.label+" = " +elemen1.label + ";\n";
		atributos soma=verificacaoTipos(temp,operador.substr(0,1),elemen2);
		atributos tipo2;
		tipo2.label=GerarRegistrador();
		tipo2.tipo=soma.tipo;
		insereTabela(tipo2.label,tipo2.tipo,true,"");
		if (temp.tipo=="int"&&elemen2.tipo=="float") temp=soma;
		else if(elemen2.tipo=="int" && temp.tipo=="float") elemen2=soma;
		tipo2.traducao=soma.traducao+"\t"+tipo2.label+"="+temp.label+operador.substr(0,1)+elemen2.label+";\n";
		atributos elemento=verificacaoTipos(elemen1,"=",tipo2);
		if(tipo2.tipo=="int" && elemen1.tipo=="float") tipo2=elemento;
		atributos fim;
		fim.label=elemen1.label;
		fim.tipo=elemen1.tipo;
		fim.traducao=elemento.traducao+"\t"+elemen1.label+"="+tipo2.label+";\n";
			return fim;
	}else{
		TIPO_SIMBOLO variavel=verificaDeclaracao(elemen1.label);
		elemen1.label=variavel.nomeVariavel;
		elemen1.tipo=variavel.tipoVariavel;
		atributos temp;
		temp.label=GerarRegistrador();
		temp.tipo=elemen1.tipo;
		insereTabela(temp.label,temp.tipo,true,"");
		temp.traducao="\t"+ temp.label+" = " +elemen1.label + ";\n";
		elemen2.tipo="int";
		elemen2.label=GerarRegistrador();
		insereTabela(elemen2.label,elemen2.tipo,true,"");
		elemen2.traducao ="\t"+ elemen2.label+" = 1;\n";
		atributos soma=verificacaoTipos(temp,operador.substr(0,1),elemen2);
		atributos tipo2;
		tipo2.label=GerarRegistrador();
		tipo2.tipo=soma.tipo;
		insereTabela(tipo2.label,tipo2.tipo,true,"");
		if (temp.tipo=="int"&&elemen2.tipo=="float") temp=soma;
		else if(elemen2.tipo=="int" && temp.tipo=="float") elemen2=soma;
		tipo2.traducao=soma.traducao+"\t"+tipo2.label+"="+temp.label+operador.substr(0,1)+elemen2.label+";\n";
		atributos elemento=verificacaoTipos(elemen1,"=",tipo2);
		if(tipo2.tipo=="int" && elemen1.tipo=="float") tipo2=elemento;
		atributos fim;
		fim.label=elemen1.label;
		fim.tipo=elemen1.tipo;
		fim.traducao=elemento.traducao+"\t"+elemen1.label+"="+tipo2.label+";\n";
			return fim;
	}
}

void yyerror( string MSG ){
	cout << MSG << endl;
	exit (0);
}				
