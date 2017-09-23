build:
	gcc -std=c99 tp1.c -Wall -Werror -Wpedantic -o tp1 

informe:
	pdflatex informe.tex
