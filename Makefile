ML_SRC=src/pureSplitMix.ml \
	   src/pureSplitMix.mli
ML_OUT=pureSplitMix.cma \
	   pureSplitMix.cmxa

TEST_SRC=test/test.ml
TEST_EXE=test.native

REF_SRC=test/ref.java
REF_EXE=test/Main.class

.PHONY: build test

build: $(ML_SRC)
	ocamlbuild -I src/ $(ML_OUT)

test: $(TEST_EXE)
	./$(TEST_EXE) > test.out
	diff test.out ref.out

$(TEST_EXE): $(ML_SRC) $(TEST_SRC)
	ocamlbuild -I src test/$(TEST_EXE)

ref.out: $(REF_EXE)
	java -classpath test Main > ref.out

$(REF_EXE): $(REF_SRC)
	javac $(REF_SRC)
