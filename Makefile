SOURCES=src/main.c
CFLAGS=-Wall -Werror -fsanitize=address
INCLUDES=-Ivendor/minimp3
CC=clang

all: release

release: $(SOURCES)
	$(CC) $(CFLAGS) $(INCLUDES) -O3 $^ -o decoder

debug: $(SOURCES)
	$(CC) $(CFLAGS) $(INCLUDES) -g $^ -o decoder_debug

clean:
	@rm -rf ./decoder*
