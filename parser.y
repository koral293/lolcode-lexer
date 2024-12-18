%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

extern FILE *yyin;

typedef struct Symbol {
    char *name;
    char *value;
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;

Symbol* create_symbol(const char *name, const char *value) {
    Symbol *symbol = (Symbol *)malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->value = value ? strdup(value) : NULL;
    symbol->next = NULL;
    return symbol;
}

Symbol* find_symbol(const char *name) {
    Symbol *symbol = symbol_table;
    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            return symbol;
        }
        symbol = symbol->next;
    }
    return NULL;
}

void add_symbol(Symbol *symbol) {
    symbol->next = symbol_table;
    symbol_table = symbol;
}

void set_symbol_value(const char *name, const char *value) {
    Symbol *symbol = find_symbol(name);
    if (symbol) {
        free(symbol->value);
        symbol->value = strdup(value);
    } else {
        symbol = create_symbol(name, value);
        add_symbol(symbol);
    }
}

char *process_characters(const char *str) {
    size_t len = strlen(str);
    char *result = (char *)malloc(len + 1);
    char *dst = result;
    const char *src = str;

    while (*src) {
        if (*src == ':') {
            switch(*(src + 1)) {
                case ')':
                    *dst++ = '\n';
                    break;
                case '>':
                    *dst++ = '\t';
                    break;
                default:
                    *dst++ = *src;
                    *dst++ = *(src + 1);
            }
            src += 2;
        }
        else {
            *dst++ = *src++;
        }
    }


    *dst = '\0';
    return result;
}

%}

%union {
    int num;
    char *str;
}

%token HAI KTHXBYE NEWLINE VISIBLE BTW VERSION
%token IHASA ITZ R AN
%token <num> NUMBER
%token <str> STRING
%token <str> IDENTIFIER

%type <str> value values

%%

program:
    HAI VERSION NEWLINE statements KTHXBYE
    |
    HAI VERSION NEWLINE statements KTHXBYE NEWLINE
    ;

statements:
    |
    statements statement NEWLINE
    ;

statement:
    VISIBLE values { printf("%s\n", $2); free($2); }
    |
    IHASA IDENTIFIER ITZ value { set_symbol_value($2, $4); free($2); free($4); };
    |
    IHASA IDENTIFIER { set_symbol_value($2, NULL); free($2); }
    |
    IDENTIFIER R value { set_symbol_value($1, $3); free($1); }
    |
    BTW STRING { /* Comment */ }
    ;

values:
    value { $$ = $1; }
    |
    values AN value {
        char *temp = (char *)malloc(strlen($1) + strlen($3) + 2);
        strcpy(temp, $1);
        strcat(temp, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    ;

value:
    NUMBER {
        char buffer[32];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    |
    STRING {
        $$ = process_characters($1);
        free($1);
    }
    |
    IDENTIFIER {
        Symbol *symbol = find_symbol($1);
        if (symbol && symbol->value) {
            $$ = strdup(symbol->value);
        } else {
            yyerror("Undefined variable");
            $$ = strdup("");
        }
        free($1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s", s);
}

void interpret(const char *str) {
    printf("%s\n", str);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();

    Symbol *symbol = symbol_table;
    while (symbol) {
        Symbol *next = symbol->next;
        free(symbol->name);
        free(symbol->value);
        free(symbol);
        symbol = next;
    }

    return 0;
}