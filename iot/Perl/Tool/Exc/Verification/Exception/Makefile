# Makefile to drive Perl modules 
# Date auto-generated: Thu Oct  5 09:03:32 PDT 2017
# By: pwalsh

# P Walsh Jan 2016 

# Targets 
#   bats --- make batch tester from tb.cew 
#   clean 
#   cover --- test coverage
#   tidy --- indent code in .pl, .pm  and .cew files 

# directory where scripts are located and temp file
SD=../../../Cew
CUT=../../Exception.pm

# code beautifier 
INDENT=perltidy -i=3 

bats: tb.pl translate
	perl tb.pl

translate: 
	@((cd ../../../; $(MAKE) translate;) > /dev/null 2>&1)

cover: tb.pl 
	perl -MDevel::Cover tb.pl
	@cover -select $(CUT) -report text > $(CUT).cover
	@rm -r cover_db

tb.pl: tb.cew 
	@rm -f $(SD)/tmp/tb.num
	@rm -f ./tb.pl
	@awk -f $(SD)/bin/addLineNums.awk tb.cew > $(SD)/tmp/tb.num
	@m4 -I $(SD)/bin $(SD)/tmp/tb.num  | $(INDENT) > tb.pl

tb.cew:
	@cp $(SD)/Template/tb.cew .

clean:
	@rm -f  $(SD)/tmp/* tb.pl $(CUT).cover *.cover $(CUT).tdy *.tdy *.ERR

tidy:
	@$(INDENT) $(CUT) *.pl *.cew

