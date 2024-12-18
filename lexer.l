%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>
%}

%option noyywrap

%%

"HAI"           { return HAI; }
"1.0"           { return VERSION; }
"1.1"           { return VERSION; }
"1.2"           { return VERSION; }
"KTHXBYE"       { return KTHXBYE; }
"VISIBLE"       { return VISIBLE; }
"I HAS A"       { return IHASA; }
"ITZ"           { return ITZ; }
"R"             { return R; }
"AN"            { return AN; }
"\n"            { return NEWLINE; }
","             { return NEWLINE; }
"BTW"           { return BTW; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
\"[^\"]*\"      { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = 0; return STRING; }
[a-zA-Z][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return IDENTIFIER; }
[ \t]+          { /*  */ }
.               { return yytext[0]; }

%%