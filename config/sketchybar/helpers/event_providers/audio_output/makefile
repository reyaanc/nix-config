bin/audio_output: audio_output.c ../sketchybar.h | bin
	clang -std=c99 -O3 -framework CoreAudio -framework AudioToolbox -framework CoreFoundation $< -o $@

bin:
	mkdir bin
