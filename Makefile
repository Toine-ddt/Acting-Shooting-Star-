SRC= src/actor.rkt  
TEST_MAIN= tst/test.rkt

all: build

build: main doc


main: src/main.rkt
	racket src/main.rkt -f 60

test: tst/actor-test.rkt src/actor.rkt tst/world-test2.rkt src/runtime.rkt
	racket tst/world-test2.rkt
	racket tst/actor-test.rkt

doc: actors.scrbl
	scribble --dest doc actors.scrbl


clean: 
	rm -f  doc/*.css doc/*.js doc/*.html

#test: racket $(TEST_MAIN)



