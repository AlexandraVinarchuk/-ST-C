/* Строки, заключенные в %{%}, напрямую скопируются в сгенерированный парсер */
%{
    #include <string.h>

    /* Подключаем сгенерированный заголовочный файл bison, чтобы у flex был доступ к названиям токенов */
    #include "bison.tab.h"

    void yyerror(char* s); // Объявляем функцию печати ошибок
%}

/* Отключает функцию для работы с несколькими входными файлами */
%option noyywrap

%% /* Разделитель области объявлений и области правил языка */

":="                    {
                            /* Знак присваивания */
                            return ASSIGN_SIGN; 
                        }                    

[+-]                    {
                            /* Арифметические знаки */
                            strcpy(yylval.str, yytext); 

                            return ARITHMETIC_SIGN;
                        }

"<="|">="|[<>]          {
                            /* Знаки сравнения */
                            strcpy(yylval.str, yytext); 

                            return COMPARE_SIGN;
                        }

"<>"                    {
                            /* Знак неравенства */
                            strcpy(yylval.str, "!="); 

                            return COMPARE_SIGN;
                        }

"="                     {
                            /* Знак равенства */
                            strcpy(yylval.str, "=="); 

                            return COMPARE_SIGN;
                        }

"var"                   { 
                            /* Начало блока инициализации переменных */
                            return START_VAR; 
                        } 

"end_var"               { 
                            /* Конец блока инициализации переменных */
                            return END_VAR; 
                        } 

"if"                    {
                            /* Начало ветвления */
                            return IF;
                        } 

"then"                  {
                            /* Начало инструкций в ветвлении */
                            return THEN;
                        }

"else"                  {
                            /* Ключевое слово else */
                            return ELSE;
                        } 

"end_if"                {
                            /* Конец ветвления */
                            return END_IF;
                        }

"int"                   { 
                            /* Целочисленная переменная */
                            return INTEGER; 
                        } 

[0-9]+                  {
                            /* Целое число */
                            strcpy(yylval.str, yytext); 
                            
                            return NUM; 
                        } 

[a-zA-Z][a-zA-Z0-9_]*   {
                            /* Идентификаторы */ 
                            strcpy(yylval.str, yytext); 
                            
                            return ID;
                        }

[;:]                    { 
                            /* Отдельные символы */
                            return *yytext; 
                        }

[ \t\r\n]               {
                            /* Игнорируем символы пробелов и переходов на новую строку */
                        }

<<EOF>>                 {
                            /* Конец файла */
                            static int once = 0; // flex возвращает файл несколько раз, исправляем это 

                            return once++ ? 0 : FILE_END;
                        }

.                       { 
                            /* Печать ошибки, если символ не обработан */
                            yyerror("Unknown character"); 
                        }

%% /* Разделитель области правил языка и области объявления функций */
