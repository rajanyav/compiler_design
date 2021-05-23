{
#include<stdio.h>
#include<stdbool.h>
#include<stdlib.h>
#include<string.h>
int yylex();
void yyerror(char *s);
extern FILE *yyin;
char p[12];
void lookup(char *token,char *value,char *datatype,int scope);
typedef struct symbol_table
{
      char name[31];
    char *value;
    char *datatype;
    int scope;
    }ST;
  int struct_index = 0;
  ST st[100];



union Number
    {
        int inttype;
        double doubletype;
        bool booltype;
        char chartype;
        char identifier[31];
};

%}

%union{
int inttype;
double doubletype;
bool booltype;
char chartype;
char identifier[31];
union Number *nval;
}
%token  T_Header T_Include T_Void T_Int T_Main T_Double T_Char T_Bool
%token  T_Equal T_NotEqual T_LessEqual T_GreaterEqual T_While T_If T_Else
/*%token <nval> T_IntConst
%token <nval> T_CharConst
%token <nval> T_BoolConst
%token <nval> T_DoubleConst
%token T_Identifier
%token T_StringConst
*/
%type <nval> rhs E T F G H
%type<identifier>type


%token <inttype> T_IntConst
%token <chartype> T_CharConst
%token <booltype> T_BoolConst
%token <doubletype> T_DoubleConst
%token <identifier> T_Identifier

%locations
%%
start
    :
    header start
    | header global_decl main{printf("parsing done\n");YYACCEPT;}
    | header main{printf("parsing done\n");YYACCEPT;}

    ;

header
    :
         T_Include '<' T_Header '>'
    |T_Include '"' T_Header '"'
      ;
main
      :  T_Void T_Main main_body
    |T_Int T_Main main_body
    ;
global_decl
    :
     global_decl decl
    |decl
    ;
decl    :
    type gvariable_list ';'
    ;
type
    :T_Int  {strcpy(p,"int"); printf("%s\n",p);}
    |T_Double {strcpy(p,"double"); printf("%s\n",p);}
    |T_Char {strcpy(p,"char"); printf("%s\n",p);}
    |T_Bool {strcpy(p,"bool"); printf("%s\n",p);}
    ;
gvariable_list
    :
    T_Identifier {printf("%s\n",$1);lookup($1,NULL,p,0);}
    |T_Identifier '=' E  {printf("%s\n",$1);lookup($1,NULL,p,0);}
    | gvariable_list ',' T_Identifier {printf("%s\n",$3);lookup($3,NULL,p,0);}
    |gvariable_list ',' T_Identifier'='E {printf("%s\n",$3);lookup($3,NULL,p,0);}
    ;
rhs
    :
    T_IntConst { $<inttype>$=$1; printf("%d\n",$$);}
    |T_DoubleConst { $<doubletype>$=$1; printf("%lf\n",$$); }
    |T_CharConst { $<chartype>$=$1;printf("%c\n",$$); }
    |T_BoolConst { $<booltype>$=$1;printf("%d\n",$$); }
    ;

main_body
      : '{'statements'}'
      ;


statements
    :statements statement
    |statement
    ;

statement
    :
    local_decl
    | assign ';'
    |loops
    ;

assign  :
    T_Identifier '=' E {printf("%s\n",$1);lookup($1,NULL,p,1);}
    ;

local_decl    : type lvariable_list ';'
    ;
lvariable_list
    :
     T_Identifier',' lvariable_list {lookup($1,NULL,p,1);}
    |assign',' lvariable_list
    |assign
    |T_Identifier {printf("%s\n",$1);lookup($1,NULL,p,1);}
    ;

E
    :
    E T_Equal T { $$= $1==$3; }
    | E T_NotEqual T { $$= $1!=$3; }
    | T { $$=$1; }
    ;
T   :
    T '<' F { $$= $1<$3; }
    | T T_LessEqual F { $$= $1<=$3; }
    | T '>' F { $$= $1>$3; }
    | T T_GreaterEqual F { $$= $1>=$3; }
    | F { $$= $1; }
    ;
F
    :
    F '+' G { $$= (int)$1+(int)$3; }
    | F'-' G { $$= (int)$1-(int)$3; }
    | G { $$= $1; }
    ;
G
    :
    G '*' H { $$= (int)$1 * (int)$3; }
    | G '/' H { $$= (int)$1/(int)$3; }
    | G '%' H { $$= (int)$1%(int)$3; }
    | H { $$= $1; }
    ;
H
    :
    //T_Identifier { $$= $1; }
    rhs { $$= $1; }
    | '('E')' { $$= $2; }
;

loops   :T_If ifloop
    |T_While whileloop
    ;
ifloop  :'(' E ')' '{' statements '}'
    | '(' E ')' '{' statements '}' T_Else '{' statements '}'
    ;
whileloop:'(' E ')' '{' statements '}'

%%

void yyerror(char *s)
{

printf("%s %d\n",s,yylloc.first_line);

}
int yywrap()
{return(0);}
int main()
{
yyin = fopen("input.c","r");
if(!yyparse())
{
    printf("Parsing Complete\n");

    printf("-----------------------------------Symbol Table-----------------------------------\n\n");
    printf("S.No\t  Token \t Value \t\t Scope \t    DataType \n");
    for(int i = 0;i < struct_index;i++)
    {
    if(st[i].scope == 0)
            printf("%d\t  %s\t\t  %s\t %s\t    %s\n",i+1,st[i].name,st[i].value,"global",st[i].datatype);
    else
            printf("%d\t  %s\t\t  %s\t %s\t    %s\n",i+1,st[i].name,st[i].value,"local",st[i].datatype);
    }
  }
 else
  {
    printf("failed\n");
  }
  fclose(yyin);
  return 0;
}


void lookup(char *token,char *value,char *datatype,int scope)
{

  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token) && st[i].scope==scope)
    {

      flag = 1;
      break;
    }
  }

  if(flag == 0)
  {
    strcpy(st[struct_index].name,token);
    st[struct_index].scope=scope;
    if(value==NULL)
        st[struct_index].value=NULL;
    else
    {
        st[struct_index].value=(char*)malloc(sizeof(char)*(strlen(value)+1));
        strcpy(st[struct_index].value,value);
     }
        if(datatype==NULL)
        st[struct_index].datatype=NULL;
    else
    {
        st[struct_index].datatype=(char*)malloc(sizeof(char)*(strlen(datatype)+1));
        strcpy(st[struct_index].datatype,datatype);
     }
   struct_index++;
  }
}
