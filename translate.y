%locations

%{
    
#include<stdio.h>

#define yyerrok
int yylineno;
int mute;

void printLine();

void process(char *str);

void markError(int flag);

%}

// 之前lex.l裡面用 #define 定義的token被搬來這裡了
%token LT LE EQ NE GT GE IF ELSE ID NUMBER RELOP ABSTRACT ASSERT BOOLEAN BREAK BYTE CASE CATCH CHAR CLASS CONTINUE DEFAULT DO DOUBLE ENUM EXPORTS EXTENDS FINAL FINALLY FLOAT FOR IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE LONG MODULE NATIVE NEW PACKAGE PRIVATE PROTECTED PUBLIC REQUIRES RETURN SHORT STATIC STRICTFP SUPER SWITCH SYNCHRONIZED THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE TRUE NULL_J FALSE VAR ASSIGN KEYWORD L_BRA R_BRA D_QUO S_QUO QUE SEM L_PAR R_PAR MOD SPLA R_SPLA TILDE MUP OR OPR_ADD OPR_MIN AND COM L_M_BRA R_M_BRA COLON DOT D_PLU D_MIN O_OR O_AND TEXT

%%

// 能夠解析多行的關鍵在此
start:      line
            | start line
            ; 

// 每一行裡面可以出現的東西都定義在這裡
line:       pkg
            | class
            | error_method                                  {markError(0); yyerrok;}
            ;

// 定義java的package
pkg:        PACKAGE rep_id ';'                              {printLine(); process("package\n");}
            ;

// pkg_name:   ID '.' pkg_name
//             | ID
//             ;

// class
class:      class_head class_body    
            ;

class_head:     access_level static CLASS                   {printLine(); process("class\n");}
                ;

class_body:     ID class_codeblock
                ;

// class中的內容
class_codeblock:    '{' class_stmt_list '}'                 
                    ;

class_stmt_list:    class_stmt_list class_stmt              //{printLine(); process("Statement inside class\n");}
                    |
                    ;

class_stmt:         full_declare                            {printLine(); process("Statement inside class\n");}//{printLine(); process("declare\n");}
                    | method                                //{printLine(); process("method\n");}
                    ;

// method
method:             method_head method_body
                    ;

method_head:        access_level static final return_type   {printLine(); process("method\n");}
                    ;

method_body:        ID '(' parameter ')' method_codeblock
                    ;

// method的參數
parameter:          parameter ',' s_parameter
                    | s_parameter
                    | ;

s_parameter:        type_key ID
                    | type_key '[' ']' ID;

return_type:        type_key
                    | VOID
                    | ID;

// method中的內容
method_codeblock:   '{' method_stmt_list '}'
                    ;

method_stmt_list:   method_stmt_list method_stmt             
                    | 
                    ;

method_stmt:        method_declare                          //{printLine(); process("declare inside method\n");}
                    | prg                                   
                    | func_call ';'                         //{printLine(); process("function call inside method\n");}
                    | stmt                                  {printLine(); process("statement inside method\n");}
                    | error_class                            {markError(0); yyerrok;}
                    ;

full_declare:       access_level static final declare       //{printLine(); process("declare\n");}
                    ;

method_declare:     final declare                           {printLine(); process("declare\n");}//{printLine(); process("declare inside method\n");}
                    ;  
// 各種存取層級
access_level:    PUBLIC                                     //{printLine(); process("public\n");}
                | PROTECTED
                | PRIVATE
                | 
                ;

// 靜態與否
static:         STATIC
                | 
                ;

// 常數與否
final:          FINAL                                      {printLine(); process("declare inside method\n");}
                | 
                ;

// for、for each、while、do/while、if、if/else
prg:        for_head lbody 	
            | for_each_head lbody          
            | while_head lbody			            
            | do_head codeblock WHILE '(' cond ')' ';'   
            | if '(' cond ')' lbody				            
            | if '(' cond ')' lbody	ELSE lbody		        
            ;

for_head:   FOR '(' f_declare ';' cond ';' lexp ')'         {printLine(); process("For loop\n");}
            ;

for_each_head: FOR '(' type_key ID ':' ID ')'               {printLine(); process("For each loop\n");}
            ;

while_head: WHILE '(' cond ')'                              {printLine(); process("While loop\n");}
            ;

do_head:    DO                                              {printLine(); process("DO while\n");}
            ;

if:         IF                                              {printLine(); process("IF/ELSE\n");}
            ;

// Statement 和 程式碼區段 ( { } 之間的多行statement)
lbody:      stmt                                            //{printLine(); process("Statement\n");}
            | codeblock
            ;

codeblock:  '{' stmt_list '}'
            ;

stmt_list:  stmt_list stmt                                  //{printLine(); process("Statement in code block\n");}
            |
            ;

stmt:       lexp ';'                                        {printLine(); process("statement inside method\n");}
            | declare
            | prg
            ;

// 錯誤定義區
error_class:        error_class_head class_body 
                    ;

error_class_head:   class_head           {process("^^^^^ [Error] Class should not be declared here!\n"); markError(1);}
                    ;

error_method:        error_method_head method_body 
                    ;

error_method_head:   method_head         {process("^^^^^ [Error] Method should not be declared here!\n"); markError(1);}
                    ;

// 讓for迴圈的第一項中能放入變數宣告
f_declare:  lexp
            | type_key fexp 
            |
            ;

// 變數的宣告
declare:    type_key lexp ';'
            | ID lexp ';'                                   
            | array_declare                                 {process("[ARRAY] ");}
            ;

lexp:       fexp			
            |				
            ;

fexp:       fexp ',' exp		
            | exp
            |'(' fexp ')'			
            ;

// expression - 表達式，其中包刮
// ID [+-*/] ID
// ID++ 或 ID--
// ID 或 NUMBER
exp:        ID BOP exp			
            | ID UOP			
            | UOP ID
            | ID
            | NUMBER
            | ID ASSIGN NEW ID '(' argument ')'     {process("[OBJECT] ");}
            | func_call                             {process("[FUNC CALL] ");}
            | RETURN
            ;

func_call:  rep_id '(' argument ')'                 //{printLine(); process("function call inside method\n");}
            | ID '(' argument ')'                   //{printLine(); process("function call inside method\n");}
            ;

array_declare:      type_key '[' ']' a_mid a_exp ';'
                    ;

a_mid:              '[' ']' a_mid
                    | 
                    ;

a_exp:              a_exp ',' arr		/*comma separated exp*/
                    | arr
                    ;

arr:                ID ASSIGN NEW type_key '[' NUMBER ']'
                    | ID ASSIGN arr_fill
                    ;

arr_fill:   '{' argument '}'
            ;

argument:   argument ',' nid
            | nid
            | ;

arg_opr:    ;   

// condition - 條件式

cond:       scond
	        | scond logop cond
	        ;

scond:      nid
	        | nid relop nid
            | boolean
            | lexp
	        ;

// 布林值
boolean:    TRUE
            | FALSE
            ;

// NUMBER or ID
nid:        ID
	        | NUMBER
            | rep_id
	        ;

rep_id:     ID '.' rep_id
            | ID
            ;

// logic operator 邏輯運算子
logop:      AND
	        | OR
	        ;

// relation operator 關係運算子
relop:      LT
	        | LE
	        | EQ
	        | NE
	        | GT
	        | GE
	        ;

// operator 各種算術用的運算子
opr:        MOD
            | SPLA
            | TILDE
            | MUP
            | O_OR
            | OPR_ADD
            | OPR_MIN
            | O_AND
            ;

// ++ 和 -- 符號
UOP:        D_PLU
            | D_MIN
            ;

// 能放在ID與NUMBER之間的運算子
BOP:        ASSIGN
            | logop
            | relop
            | opr
            ;

// 各種用於宣告型態的關鍵字
type_key:   BOOLEAN
            | BYTE
            | CHAR
            | FLOAT
            | INT
            | LONG
            | SHORT
            | VAR
            | LONG
            | SHORT
            | ID
            ;
%%

int main() {
    yyparse();
    return 0;
}