%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #define YYSTYPE char *
  int yylex();
  void yyerror(char *);
  void lookup(char *,int,char,char*,char*);
  //void insert(char *,int,char,char*,char* );
  void update(char *,int,char *);
  void search_id(char *,int );
  extern FILE *yyin;
  extern int yylineno;
  extern char *yytext;
  typedef struct symbol_table
  {
    int line;
    char name[31];
    char type;
    char *value;
    char *datatype;
  }ST;
  int struct_index = 0;
  ST st[10000];
  char x[10];
%}
%start S
%token ID NUM T_lt T_gt T_lteq T_gteq T_neq T_eqeq T_and T_or T_incr T_decr T_not T_eq WHILE INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK CONTINUE IF ELSE COUT STRING FOR ENDL T_ques T_colon //T_Identifier

%token T_pl T_min T_mul T_div
%left T_lt T_gt
%left T_pl T_min
%left T_mul T_div
//%token <identifier> T_Identifier


%%
S
      :START {printf("\n\n\nINPUT ACCEPTED.\n");}
      ;
     // START S
   // | START global_decl MAIN{printf("parsing done\n");YYACCEPT;}
    //| START MAIN{printf("parsing done\n");YYACCEPT;}

START
      : INCLUDE T_lt H T_gt MAIN {lookup($1,@1.last_line,'K',NULL,NULL);}
      | INCLUDE "\"" H "\"" MAIN {lookup($1,@1.last_line,'K',NULL,NULL);}
      ;

MAIN
      : VOID MAINTOK BODY {lookup($1,@1.last_line,'K',NULL,NULL);lookup($2,@1.last_line,'K',NULL,NULL);}
      | INT MAINTOK BODY {lookup($1,@1.last_line,'K',NULL,NULL);lookup($2,@1.last_line,'K',NULL,NULL);}
      ;

BODY
      : '{' C '}'
      ;

C
      : C statement ';'
      | C LOOPS
      | statement ';'
      | LOOPS
      ;

LOOPS
      : WHILE ')' LOOPBODY {lookup($1,@1.last_line,'K',NULL,NULL);}
      | FOR '(' ASSIGN_EXPR ';' COND ';' statement ')' LOOPBODY {lookup($1,@1.last_line,'K',NULL,NULL);}
      | IF '(' COND ')' LOOPBODY {lookup($1,@1.last_line,'K',NULL,NULL);}
      | IF '(' COND ')' LOOPBODY ELSE LOOPBODY {lookup($1,@1.last_line,'K',NULL,NULL);lookup($6,@1.last_line,'K',NULL,NULL);}
      ;


LOOPBODY
      : '{' LOOPC '}'
      | ';'
      | statement ';'
      ;

LOOPC
      : LOOPC statement ';'
      | LOOPC LOOPS
      | statement ';'
      | LOOPS
      ;

statement
      : ASSIGN_EXPR
      | EXP
      | TERNARY_EXPR
      | PRINT
      ;

COND
      : LIT RELOP LIT
      | LIT
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop '(' LIT RELOP LIT ')'
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop '(' LIT ')'
      | un_boolop LIT
      ;

ASSIGN_EXPR
      : ID T_eq EXP {search_id($1,@1.last_line);lookup($2,@2.last_line,'O',NULL,NULL);update($1,@1.last_line,$3);}
      | TYPE ID T_eq EXP {lookup($2,@1.last_line,'I',NULL,$1);lookup($3,@3.last_line,'O',NULL,NULL);update($2,@1.last_line,$4);}
      | error ';'
      ;

EXP
      : ADDSUB
      | EXP T_lt ADDSUB {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)<atoi($3));} //printf("%s\n",$$);}
      | EXP T_gt ADDSUB {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)>atoi($3));} //printf("%s\n",$$);}
      ;

ADDSUB
      : TERM
      | EXP T_pl TERM {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)+atoi($3));} //printf("%s\n",$$);}
      | EXP T_min TERM {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)-atoi($3));} //printf("%s\n",$$);}
      ;

TERM
      : FACTOR
      | TERM T_mul FACTOR {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)*atoi($3));} //printf("%s\n",$$);}
      | TERM T_div FACTOR {lookup($2,@1.last_line,'O',NULL,NULL);sprintf($$,"%d",atoi($1)/atoi($3));} //printf("%s\n",$$);}
      ;

FACTOR
      : LIT
      | '(' EXP ')'
      ;

TERNARY_EXPR
      : '(' COND ')' T_ques ternary_statement {lookup($4,@4.last_line,'O',NULL,NULL);}
      ;

ternary_statement
      : statement T_colon statement {lookup($2,@2.last_line,'O',NULL,NULL);}
      ;

PRINT
      : COUT T_lt T_lt STRING {lookup($1,@1.last_line,'K',NULL,NULL);lookup($4,@1.last_line,'C',NULL,NULL);}
      | COUT T_lt T_lt STRING T_lt T_lt ENDL {lookup($1,@1.last_line,'K',NULL,NULL);lookup($4,@1.last_line,'C',NULL,NULL);lookup($7,@1.last_line,'K',NULL,NULL);}
      ;
LIT
      : ID {search_id($1,@1.last_line);sprintf($$,"%d",atoi(get_val($1)));}
      | NUM {lookup($1,@1.last_line,'C',NULL,NULL);}
      ;
TYPE
      : INT {lookup($1,@1.last_line,'K',NULL,NULL);}
      | CHAR {lookup($1,@1.last_line,'K',NULL,NULL);}
      | FLOAT {lookup($1,@1.last_line,'K',NULL,NULL);}
      ;
RELOP
      : T_lt {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_gt {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_lteq {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_gteq {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_neq {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_eqeq {lookup($1,@1.last_line,'O',NULL,NULL);}
      ;
/*
assign  :
    T_Identifier '=' RELOP {printf("%s\n",$1);lookup($1,NULL,p,1);}
    ;

lvariable_list
    :
     T_Identifier',' lvariable_list {lookup($1,NULL,p,1);}
    |assign',' lvariable_list
    |assign
    |T_Identifier {printf("%s\n",$1);lookup($1,NULL,p,1);}
    ;
*/

bin_boolop
      : T_and {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_or {lookup($1,@1.last_line,'O',NULL,NULL);}
      ;
/*
un_arop
      : T_incr {lookup($1,@1.last_line,'O',NULL,NULL);}
      | T_decr {lookup($1,@1.last_line,'O',NULL,NULL);}
      ;
*/
un_boolop
      : T_not {lookup($1,@1.last_line,'O',NULL,NULL);}
      ;

//local_decl    : TYPE lvariable_list ';'
  //  ;
/*
type
    :INT  {strcpy(p,"int"); printf("%s\n",p);}
    //|T_Double {strcpy(p,"double"); printf("%s\n",p);}
    |CHAR {strcpy(p,"char"); printf("%s\n",p);}
    //|T_Bool {strcpy(p,"bool"); printf("%s\n",p);}
    ;
statement     :
    local_decl
    | assign ';'
    |LOOPS
    ;
statements    :statements statement
    |statement
    ;

main_body
      : '{'statements'}'
      ;

gvariable_list
    :
    T_Identifier {printf("%s\n",$1);lookup($1,NULL,p,0);}
    |T_Identifier '=' ASSIGN_EXPR  {printf("%s\n",$1);lookup($1,NULL,p,0);}
    | gvariable_list ',' T_Identifier {printf("%s\n",$3);lookup($3,NULL,p,0);}
    |gvariable_list ',' T_Identifier'='ASSIGN_EXPR {printf("%s\n",$3);lookup($3,NULL,p,0);}
    ;

global_decl
    :
     global_decl decl
    |decl
    ;
decl    :
    TYPE gvariable_list ';'
    ;

*/

%%

int main(int argc,char *argv[])
{
  yyin = fopen("input1.c","r");
  if(!yyparse())
  {
  if(!yyparse())  //yyparse-> 0 if success
  {
  	printf("Parsing Complete\n");
    printf("Number of entries in the symbol table = %d\n\n",struct_index);
    printf("\t\t\t S Y M B O L\t T A B L E\t\t\t\n\n");
    printf("S.No\t  Token  \t Line Number \t Category \t DataType \t Value\n");
    for(int i = 0;i < struct_index;i++)
    {

    //if(st[i].scope == 0)
            //printf("%d\t  %s\t\t  %s\t %s\t    %s\n",i+1,st[i].name,st[i].value,"global",st[i].datatype);
    //else
            //printf("%d\t  %s\t\t  %s\t %s\t    %s\n",i+1,st[i].name,st[i].value,"local",st[i].datatype);
    //}
      char *ty;
      //if(st[i].type=='I')
	//printf(
      //if(st[i].type=='K')
        //ty="keyword";
      if(st[i].type=='I')
      {
        ty="identifier";
        printf("%-4d\t  %-7s\t   %-10d \t %-9s\t  %-7s\t   %-5s",i+1,st[i].name,st[i].line,ty,st[i].datatype,st[i].value,);
     //else
       // printf("%-4d\t  %-7s\t   %-10d \t %-9s\t  %-7s\t   %-5s   %s\n",i+1,st[i].name,st[i].line,ty,st[i].datatype,st[i].value,"local");
      //}

//else if(st[i].type=='C')
        //ty="constant";
      //else
       //ty="operator";

  //if(st[i].type!='I')
    //printf("%-4d\t  %-7s\t   %-10d\t %-9s\t  NULL\t\t %-5s\n",i+1,st[i].name,st[i].line,ty,st[i].value);
    }
  }
  else
  {
    printf("failed\n");
  }
  fclose(yyin);
  return 0;
}


void yyerror(char *s)
{
  printf("Error :%s at %d \n",yytext,yylineno);
}
void lookup(char *token,int line,char type,char *value,char *datatype)
{
  //printf("Token %s line number %d\n",token,line);
  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;

      if(st[i].line != line)
      {
        st[i].line = line;
      }
    }
  }

  //Insert
  if(flag == 0)
  {
    strcpy(st[struct_index].name,token);
    st[struct_index].type=type;
    st[struct_index].scope=scope;
    if(value==NULL)
        st[struct_index].value=NULL;
    else
        strcpy(st[struct_index].value,value);

    if(datatype==NULL)
        st[struct_index].datatype=NULL;
    else
        st[struct_index].datatype=datatype;

    st[struct_index].line = line;
    struct_index++;
  }
}

void search_id(char *token,int lineno)
{
  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      return;
    }
  }
  if(flag == 0)
  {
    printf("Error at line %d : %s is not defined\n",lineno,token);
    exit(0);
  }
}

void update(char *token,int lineno,char *value)
{
  int flag = 0;

  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      st[i].value = (char*)malloc(sizeof(char)*strlen(value));
      //sprintf(st[i].value,"%s",value);
      strcpy(st[i].value,value);
      st[i].line = lineno;
      return;
    }
  }
  if(flag == 0)
  {
    printf("Error at line %d : %s is not defined\n",lineno,token);
    exit(0);
  }
}

int get_val(char *token)
{
  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      return st[i].value;
    }
  }
  if(flag == 0)
  {
    printf("Error at line : %s is not defined\n",token);
    exit(0);
  }
}
