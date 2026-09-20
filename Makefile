GPR     := rogue_engine.gpr
MAIN    := tests
GNATFLAGS :=

.PHONY: all test clean

all: test

test:
	@mkdir -p obj
	gprbuild -p -P $(GPR) $(GNATFLAGS)
	./$(MAIN)
	gnatmake -gnatwa -gnat2022 tests_ops_scenario.adb
	./tests_ops_scenario

clean:
	gprclean -P $(GPR) || true
	rm -f $(MAIN)
	rm -rf obj
