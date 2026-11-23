bin/vpn_status: vpn_status.c ../sketchybar.h | bin
	clang -std=c99 -O3 -framework SystemConfiguration -framework CoreFoundation $< -o $@

bin:
	mkdir bin
