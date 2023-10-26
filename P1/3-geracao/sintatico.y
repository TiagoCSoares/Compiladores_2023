%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c"
#include "utils.c"
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO

%start programa
/*VV precedência, o com maior precedência é T_VEZES e T_DIV*/
%left T_E T_OU
%left T_IGUAL 
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho variaveis 
        { fprintf(yyout, "\tAMEM\n"); }    
     T_INICIO lista_comandos T_FIM
        { fprintf(yyout, "\tDMEM\n"); }
        { fprintf(yyout, "\tFIMP\n"); }
    ;

cabecalho 
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }     // escreve no arquivo após ler o cabecalho
    ;

variaveis
    : /* vazio */
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_LOGICO 
    | T_INTEIRO
    ;

lista_variaveis
    : T_IDENTIF lista_variaveis
    | T_IDENTIF
    ;

lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando 
    : entrada_saida
    | atribuicao
    | selecao
    | repeticao
    ;

entrada_saida   
    : entrada
    | saida
    ;

entrada
    : T_LEIA T_IDENTIF
        { 
            fprintf(yyout, "\tLEIA\n"); 
            fprintf(yyout, "\tARZG\n"); 
        }
    ;

saida 
    : T_ESCREVA expressao
        { fprintf(yyout, "\tESCR\n"); }
    ;

atribuicao
    : T_IDENTIF T_ATRIB expressao
        { fprintf(yyout, "\tARZG\n"); }
    ;

selecao
    : T_SE expressao T_ENTAO 
        { fprintf(yyout, "\tDSVF\tLx\n"); }
      lista_comandos T_SENAO 
        { 
            fprintf(yyout, "\tDSVS\tLy\n"); 
            fprintf(yyout, "Lx\tNADA\n"); 
        }
      lista_comandos T_FIMSE
        { fprintf(yyout, "Ly\tNADA\n"); }
    ;

repeticao
    : T_ENQTO 
        { fprintf(yyout, "Lx\tNADA\n"); }
      expressao T_FACA 
        { fprintf(yyout, "\tDSVF\tLy\n"); }
      lista_comandos T_FIMENQTO
      {
            fprintf(yyout, "\tDSVS\tLx\n");
            fprintf(yyout, "Ly\tNADA\n");
      }
    ;

expressao 
    : expressao T_VEZES expressao
        { fprintf(yyout, "\tMULT\n"); }
    | expressao T_DIV expressao
        { fprintf(yyout, "\tDIVI\n"); }
    | expressao T_MAIS expressao
        { fprintf(yyout, "\tSOMA\n"); }
    | expressao T_MENOS expressao
        { fprintf(yyout, "\tSUBT\n"); }
    | expressao T_MAIOR expressao
        { fprintf(yyout, "\tCMMA\n"); }
    | expressao T_MENOR expressao
        { fprintf(yyout, "\tCMME\n"); }
    | expressao T_IGUAL expressao
        { fprintf(yyout, "\tCMIG\n"); }
    | expressao T_E expressao
        { fprintf(yyout, "\tCONJ\n"); }
    | expressao T_OU expressao
        { fprintf(yyout, "\tDISJ\n"); }
    | termo
    ;

termo
    : T_IDENTIF
        { fprintf(yyout, "\tCRVG\n"); }
    | T_NUMERO
        { fprintf(yyout, "\tCRCT\t%s\n", atomo); }
    | T_V
        { fprintf(yyout, "\tCRCT\t1\n"); }
    | T_F
        { fprintf(yyout, "\tCRCT\t0\n"); }
    | T_NAO termo
        { fprintf(yyout, "\tNEGA\n"); }
    | T_ABRE expressao T_FECHA
    ;
%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;          //pular para o próximo nome,    o primeiro nome é o nome do executável, por isso o salto
    if (argc < 2) {        //caso o único argumento seja o nome do executável então explicar como executar ele
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");        //caso haja a extensão .simples vamos apagar a extensão
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);            //coloca a extensão, assim tratamos o caso quando não houve passagem da extensão
    strcat(nameIn, ".simples");         
    strcpy(nameOut, argv[0]);           // gera um novo arquivo com o mesmo nome mas com a extensão .mvs como arquivo de saída
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {                                // caso o arquivo não abra
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n");
    return 0;
}