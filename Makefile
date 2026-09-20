GPR     := rogue_engine.gpr
MAIN    := tests
GNATFLAGS :=

.PHONY: all test clean

all: test

test:
	@mkdir -p obj
	gprbuild -p -P $(GPR) $(GNATFLAGS)
	./$(MAIN)

clean:
	gprclean -P $(GPR) || true
	rm -f $(MAIN)
	rm -rf obj
