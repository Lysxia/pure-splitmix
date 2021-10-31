ML_SRC=src/pureSplitMix.ml \
	   src/pureSplitMix.mli
ML_OUT=pureSplitMix.cma \
	   pureSplitMix.cmxa

TEST_SRC=test/test.ml
TEST_EXE=test.native

REF_SRC=test/ref.java
REF_EXE=test/Main.class

.PHONY: build test

build:
	dune build

test: $(TEST_EXE)
	./$(TEST_EXE) > test/test.out
	diff test/test.out test/ref.out

$(TEST_EXE): build $(TEST_SRC)
	ocamlbuild -package pure-splitmix test/$(TEST_EXE)

ref.out: $(REF_EXE)
	java -classpath test Main > test/ref.out

$(REF_EXE): $(REF_SRC)
	javac $(REF_SRC)

clean:
	$(RM) -r _build test/*.o test/*.cmi test/*.cmx
