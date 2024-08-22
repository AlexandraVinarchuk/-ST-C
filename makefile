all:
	flex flex.l
	bison.exe -d bison.y
	gcc lex.yy.c bison.tab.c