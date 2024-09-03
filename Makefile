SOURCES=main.c
CFLAGS=-Wall -Werror -fsanitize=address
INCLUDES=-Ivendor/minimp3

all: decoder

decoder: $(SOURCES)
	clang $(CFLAGS) $(INCLUDES) $^ -o $@

decoder_debug: $(SOURCES)
	clang $(CFLAGS) $(INCLUDES) -g $^ -o $@
