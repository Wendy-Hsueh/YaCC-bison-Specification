%option yylineno

%{

#include "translate.tab.h"

#define yyerrok
int yylineno;
int mute = 0;

void yyerror(const char *msg);
void unrecognized_char(char c);

int installID();
int installNum();

void printLine();

void process(char *str);

void markError(int flag);

%}

/* delim : Delimiter 定義分隔符號(空白、tab、換行)*/
delim   [ \t] 
/* ws : whitespace 各式空白(一個或一個以上的 delim) */
ws      {delim}+
/* letter : 單個英文字母 */
letter  [A-Za-z]
/* digit : 數字0~9 */
digit   [0-9]
/* id : 識別字 */
id      {letter}({letter}|{digit})*
/* number : 數字 */
number  {digit}+(\.{digit}+)?(E[+-]?{digit}+)?

uop	    "++"|"--"

%%


{ws}            {;}
"\n"            {;}

"if"          {return (IF); }
"else"        {return (ELSE); }
"abstract"    {return (ABSTRACT); }
"assert"      {return (ASSERT); }
"boolean"     {return (BOOLEAN); }
"break"       {return (BREAK); }
"byte"        {return (BYTE); }
"case"        {return (CASE); }
"catch"       {return (CATCH); }
"char"        {return (CHAR); }
"class"       {return (CLASS); }
"continue"    {return (CONTINUE); }
"default"     {return (DEFAULT); }
"do"          {return (DO); }
"double"      {return (DOUBLE); }
"enum"        {return (ENUM); }
"exports"     {return (EXPORTS); }
"extends"     {return (EXTENDS); }
"final"       {return (FINAL); }
"finally"     {return (FINALLY); }
"float"       {return (FLOAT); }
"for"         {return (FOR); }
"implements"  {return (IMPLEMENTS); }
"import"      {return (IMPORT); }
"instanceof"  {return (INSTANCEOF); }
"int"         {return (INT); }
"interface"   {return (INTERFACE); }
"long"        {return (LONG); }
"module"      {return (MODULE); }
"native"      {return (NATIVE); }
"new"         {return (NEW); }
"package"     {return (PACKAGE); }
"private"     {return (PRIVATE); }
"protected"   {return (PROTECTED); }
"public"      {return (PUBLIC); }
"requires"    {return (REQUIRES); }
"return"      {return (RETURN); }
"short"       {return (SHORT); }
"static"      {return (STATIC); }
"strictfp"    {return (STRICTFP); }
"super"       {return (SUPER); }
"switch"      {return (SWITCH); }
"synchronized" {return (SYNCHRONIZED); }
"this"        {return (THIS); }
"throw"       {return (THROW); }
"throws"      {return (THROWS); }
"transient"   {return (TRANSIENT); }
"try"         {return (TRY); }
"void"        {return (VOID); }
"volatile"    {return (VOLATILE); }
"while"       {return (WHILE); }
"true"        {return (TRUE); }
"null"        {return (NULL_J); }
"false"       {return (FALSE); }
"var"         {return (VAR); }


"&&"            {return (AND);}
"||"            {return (OR);}
"="             {return (ASSIGN);}

"<"             { return (LT); }
"<="            { return (LE); }
"=="            { return (EQ); }
"!="            { return (NE); }
">"             { return (GT); }
">="            { return (GE); }

"%"             { return (MOD); }
"/"             { return (SPLA); }
"~"             { return (TILDE); }
"*"             { return (MUP); }
"|"             { return (O_OR); }
"+"             { return (OPR_ADD); }
"-"             { return (OPR_MIN); }
"&"             { return (O_AND); }

"++"            { return (D_PLU); }
"--"	        { return (D_MIN); }

[\.,{}();\[\]\:\"]       {return *yytext;}

{id}            { yylval = installID(); return (ID); }
{number}        { yylval = installNum(); return (NUMBER); }


%%

int installID()
{
    /*把識別字註冊進Symbol Table，並且回傳指標*/
    return ID;
}

int installNum()
{
    /*把常數值註冊進Symbol Table，並且回傳指標*/
    return NUMBER;
}

int yywrap(void) { 
    return 1;
}

void unrecognized_char(char c) {
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void yyerror(const char *msg) {
    printf("Error at line %d:\n\t%s\n", yylineno, msg);
    //exit(1);
}

void printLine() {
    printf("Line %d : ", yylineno);
}

void process(char *str) {
    if(!mute)
        printf("%s", str);
}

void markError(int flag) {
    mute = flag;
}