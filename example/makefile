CGLV_PATH = $(realpath $(shell pwd)/../)
CC = $(shell which g++)
INCL := -I/usr/local/cuda/include -I${CGLV_PATH}/include
LINK := -L/usr/local/cuda/lib64 -lcudadevrt -lcudart -lglut -lGL -lGLU -lGLEW -L${CGLV_PATH}/lib -lCuGLView

main:
	${CC} ${INCL} main.cc -o program ${LINK}

.PHONY: run
run: main
	./program

clean:
	-rm -f ./program
