SOURCES=src/main.c
CFLAGS=-Wall -Werror -fsanitize=address
INCLUDES=-Ivendor/minimp3

all: release

release: $(SOURCES)
	clang $(CFLAGS) $(INCLUDES) -O3 $^ -o decoder

debug: $(SOURCES)
	clang $(CFLAGS) $(INCLUDES) -g $^ -o decoder_debug

clean:
	@rm -rf ./decoder*
