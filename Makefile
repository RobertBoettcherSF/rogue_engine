GPR     := rogue_engine.gpr
MAIN    := tests
GNATFLAGS :=

.PHONY: all test play clean

all: test

test:
	@mkdir -p obj
	gprbuild -p -P $(GPR) $(GNATFLAGS)
	./$(MAIN)
	gnatmake -gnatwa -gnat2022 -D obj tests_ops_scenario.adb
	./tests_ops_scenario
	gnatmake -gnatwa -gnat2022 -D obj tests_demo.adb
	./tests_demo

play:
	@mkdir -p obj
	gnatmake -gnatwa -gnat2022 -D obj play.adb
	./play

clean:
	gprclean -P $(GPR) || true
	rm -f $(MAIN) tests_ops_scenario tests_demo play
	rm -rf obj
