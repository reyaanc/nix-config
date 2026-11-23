bin/power_source: power_source.c ../sketchybar.h | bin
	clang -std=c99 -O3 -framework IOKit -framework CoreFoundation $< -o $@

bin:
	mkdir bin
