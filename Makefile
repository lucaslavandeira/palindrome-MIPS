SOURCES=tp1.c *.S

build:
	gcc -std=c99 $(SOURCES) -Wall -Werror -o tp1 

informe:
	pdflatex informe.tex
