/* Строки, заключенные в %{%}, напрямую скопируются в сгенерированный парсер */
%{
    #include <stdio.h>
    #include <string.h>
    
    /* Объявление функций */
    int yylex(void);
    void yyerror(char* s);

    /* Объявление указателей на файл входа и выхода */
    extern FILE *yyin;
    extern FILE *yyout;
%}

/* Возможные типы в стеке помимо char */
%union {
    char str[256];
}

%token ID                                       /* Идентификаторы (например, имена переменных) */
%token NUM                                      /* Целое число */
%token INTEGER                                  /* Возможные типы переменных */
%token FILE_END                                 /* Конец файла */
%token START_VAR END_VAR                        /* Начало и конец зоны объявления переменных */
%token IF THEN ELSE END_IF                      /* Конструкции ветвления */
%token COMPARE_SIGN ARITHMETIC_SIGN ASSIGN_SIGN /* Знаки операций */

/* Соответствие токена типу переменной в стеке */
%type<str> ID NUM COMPARE_SIGN ARITHMETIC_SIGN operator arithmetic_operator compare_operator assign_operator variable_initialization operand

%% /* Разделитель области объявлений и области правил грамматики */

program:                regions                                                 {
                                                                                    /* Запись в файл шаблона конца программы на си */
                                                                                    fprintf(yyout, "return 0;\n}\n");

                                                                                    /* Конец обработки входного файла */
                                                                                    printf("The result is written to output.c\n"); 
                                                                                }

regions:                initialization_region END_VAR                           { 
                                                                                    /* Конец региона инициализации переменных */ 
                                                                                }
|                       regions main_region FILE_END                            {
                                                                                    /* Конец региона основной программы */
                                                                                }

initialization_region:  START_VAR                                               { 
                                                                                    /* Начало региона инициализации переменных */ 
                                                                                }
|                       initialization_region variable_initialization           { 
                                                                                    fprintf(yyout, "%s;\n", $2); 
                                                                                }

main_region:            statement                                               {
                                                                                    /* Начало региона основной программы  */
                                                                                }
|                       main_region statement                                   {
                                                                                    /* Обнаружена новая инструкция в регионе основной программы */
                                                                                }
|                       condition                                               {
                                                                                    /* Конец ветвления */
                                                                                    fprintf(yyout, "}\n")
                                                                                }
|                       main_region condition                                   {
                                                                                    /* Конец ветвления */
                                                                                    fprintf(yyout, "}\n")
                                                                                }

statement:              operator ';'                                            {
                                                                                    /* Обработка найденной инструкции */ 
                                                                                    fprintf(yyout, "%s;\n", $1) 
                                                                                }

condition:              if_condition END_IF ';'                                 {
                                                                                    /* Конец ветвления if */
                                                                                }
|                       else_condition END_IF ';'                               {
                                                                                    /* Конец ветвления if-else */
                                                                                }

else_condition:         if_condition ELSE                                       {
                                                                                    /* Обработка конструкции else */
                                                                                    fprintf(yyout, "} else {\n")
                                                                                }
|                       else_condition statement                                {
                                                                                    /* Найдена новая инструкция в else */
                                                                                }

if_condition:           IF compare_operator THEN                                {
                                                                                    /* Обработка конструкции if */
                                                                                    fprintf(yyout, "if (%s) {\n", $2)
                                                                                }
|                       if_condition statement                                  {
                                                                                    /* Найдена новая инструкция if */
                                                                                }


operator:               arithmetic_operator                                     {
                                                                                    /* Конец обработки операции с высоким приоритетом */
                                                                                }
|                       assign_operator                                         {
                                                                                    /* Конец обработки операции с низким приоритетом */
                                                                                }
|                       compare_operator                                        {
                                                                                    /* Конец обработки операции сравнения */
                                                                                }

assign_operator:        ID ASSIGN_SIGN arithmetic_operator                      {
                                                                                    /* Обработка операции присваивания результата операции */ 
                                                                                    snprintf($$, sizeof $$, "%s = %s", $1, $3);
                                                                                }
|                       ID ASSIGN_SIGN compare_operator                         {
                                                                                    /* Обработка операции присваивания результата операции */ 
                                                                                    snprintf($$, sizeof $$, "%s = %s", $1, $3);
                                                                                }
|                       ID ASSIGN_SIGN operand                                  {
                                                                                    /* Обработка операции присваивания значения переменной */
                                                                                    snprintf($$, sizeof $$, "%s = %s", $1, $3);
                                                                                }

compare_operator:       operand COMPARE_SIGN operand                            {
                                                                                    /* Обработка операции сравнения */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       arithmetic_operator COMPARE_SIGN operand                {
                                                                                    /* Обработка операции сравнения, где операндом выступает арифметическая операция */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       operand COMPARE_SIGN arithmetic_operator                {
                                                                                    /* Обработка операции сравнения, где операндом выступает арифметическая операция */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       arithmetic_operator COMPARE_SIGN arithmetic_operator    {
                                                                                    /* Обработка операции сравнения, где операндами выступают арифметические операции */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       compare_operator COMPARE_SIGN operand                   {
                                                                                    /* Обработка операции сравнения, где другая операция сравнения является операндом */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       compare_operator COMPARE_SIGN arithmetic_operator       {
                                                                                    /* Обработка операции сравнения, где операндами выступают операция сравнения и арифметическая операция */
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }

arithmetic_operator:    operand ARITHMETIC_SIGN operand                         {
                                                                                    /* Обработка операции сложения */ 
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }
|                       arithmetic_operator ARITHMETIC_SIGN operand             { 
                                                                                    /* Обработка операции сложения, где другая арифметическая операция является операндом */ 
                                                                                    snprintf($$, sizeof $$, "%s %s %s", $1, $2, $3);
                                                                                }                     

operand:                    ID                                                  {
                                                                                    /* Использование индентификатора в качестве операнда */
                                                                                }
|                           NUM                                                 {
                                                                                    /* Использование целого числа в качестве операнда */
                                                                                }

variable_initialization:    ID ':' INTEGER ';'                                  {
                                                                                    /* Обработка инициализации переменной */
                                                                                    snprintf($$, sizeof $$, "int %s", $1);
                                                                                }
|                           ID ':' INTEGER ASSIGN_SIGN NUM ';'                  {
                                                                                    /* Обработка инициализации переменной с присваиванием значения */
                                                                                    snprintf($$, sizeof $$, "int %s = %s", $1, $5);
                                                                                }

%% /* Разделитель области правил грамматики и области объявления функций */

/* Функция печати ошибок. Bison требует ее реализации. */
void yyerror(char *s)
{
    fprintf(stderr, "%s\n", s);
}

/* Точка входа в программу */
int main()
{
    /* Открытие файла входа */
    if (!(yyin = fopen("input.txt", "r")))
    {
        yyerror("Can't open input.txt");

        return -1;
    }

    /* Открытие файла выхода */
    if (!(yyout = fopen("output.c", "w")))
    {
        yyerror("Can't open output.c");

        return -1;
    }

    /* Запись в файл шаблона начала программы на си */
    fprintf(yyout, "#include <stdio.h>\n\nint main() {\n");
    
    yyparse(); // Запуск анализатора

    return 0;
}
