# Makefile to manage LightDI_155
# P Walsh Aug 2017

# Targets
#   interactive
#   clean --- clean all modules
#   tidy --- indent code in all modules 
#   runtest --- run bats in all modules
#   cover --- run cover in all modules

MODULES=Fsm/Verification/LIGHT \
        Fsm/Verification/SIC \
        Plant/Verification/SYSTEM \
	Fsm \


#.SILENT:

interactive: main.pl translate
	-@(./main.pl)

nice: main.pl translate
	-@(nice -n -10 ./main.pl)

translate:
	-@((cd ./Fsm; $(MAKE) translate;) > /dev/null 2>&1 || true)
	-@((cd ../Tosf/Fsm; $(MAKE) translate;) > /dev/null 2>&1 || true)

clean:
	-@for m in $(MODULES); do \
		#((cd $$m; $(MAKE) clean;) > /dev/null 2>&1 || true ) \
		(cd $$m; $(MAKE) clean;)\
	done

tidy:
	-@for m in $(MODULES); do \
		((cd $$m; $(MAKE) tidy;)  > /dev/null 2>&1 || true) \
	done


runtest:
	-@((cd ./Fsm; $(MAKE) translate;) > /dev/null 2>&1 || true)
	-@for m in $(MODULES); do \
		(cd $$m; $(MAKE) bats;) \
	done

cover:
	-@for m in $(MODULES); do \
		(cd $$m; $(MAKE) cover;) \
	done
