// Tabela de SImbolos

enum{
    INT, 
    LOG
};

#define TAM_TAB 100

struct  elemTabSimbolos 
{
    char id[100];   // nome do identificador   
    int end;        // endereco
    int tip;        // tipo
} tabSimb[TAM_TAB], elemTab;

int posTab = 0;    // indica a próxima posição livre para inserção

int buscaSimbolo (char *s) 
{
    int i;
    for (i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--) 
            ;
    if (i == -1) 
    {
        char msg[200];
        sprintf(msg, "Identificador [%s] não ecnontrado!", s);
        yyerror(msg);
    }
    return i;
}

void insereSimbolo (struct elemTabSimbolos elem) 
{
    int i;          
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos cheia!");                                                    //
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--) 
            ;
    if (i != -1) 
    {    // caso encontre um nome igual ao que deseja inserir já existente na tabela
    char msg[200];    // se o valor for igual a -1 a tabela foi totalmente percorrida e não foram encontradas elementos duplicados
    sprintf(msg, "Identificador [%s] duplicado!", elem.id);
    yyerror(msg);
    }
    tabSimb[posTab++] = elem;         // insere o elemento na posição posTab++
}

void mostraTabela() 
{
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("%30s | %s | %s\n", "ID", "END", "TIP");
    for(int i = 0; i < 50; i++)
        printf("-");
    for(int i = 0; i < posTab; i++)
        printf("\n%30s | %3d | %s", 
                tabSimb[i].id,
                tabSimb[i].end,
                tabSimb[i].tip == INT? "INT" : "LOG");
    puts("");
}

// Pilha Semantica
#define TAM_PIL 100
int pilha[TAM_PIL];
int topo = -1;      

void empilha (int valor) 
{
    if (topo == TAM_PIL)
        yyerror ("Pilha semantica cheia!");
    pilha[++topo] = valor;
}

int desempilha (void) 
{
    if (topo == -1)
        yyerror ("Pilha semantica vazia!");
    return pilha[topo--];      // se a pilha não for vazia retorna a nova posição da pilha após desempilhar
}
