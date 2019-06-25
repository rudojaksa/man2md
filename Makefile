PATH := $(PATH):UTIL
SRC  := $(shell find . -type f -name '*.pl' | grep -v OFF/ | xargs grep -l '\#!' | cut -b3-)
T    := $(SRC:%.pl=%)

all: $T

%: %.pl *.pl
	perlpp $< > $@
	@chmod 755 $@

install: all
	makeinstall -f $T

clean:
	rm -fv README.md
	rm -fv $T

README.md: $T
	$< -h | man2md > $@

include ~/.github/Makefile.git
