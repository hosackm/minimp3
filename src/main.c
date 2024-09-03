#include <stdio.h>
#include <stdlib.h>

#define MINIMP3_IMPLEMENTATION
#include <minimp3.h>

unsigned char *read_file(const char *filename, long *filesize)
{
    FILE *file = fopen(filename, "rb");
    if (!file)
    {
        return NULL;
    }

    if (fseek(file, SEEK_SET, SEEK_END) != 0)
    {
        return NULL;
    }

    // determine filesize and set pointer
    *filesize = ftell(file);
    rewind(file);

    // allocate enough mem to hold file
    unsigned char *contents = malloc(*filesize);
    if (!contents)
    {
        fprintf(stderr, "Couldn't allocate memory\n");
        goto error;
    }

    // read the file into memory
    if (fread(contents, 1, *filesize, file) != *filesize)
    {
        fprintf(stderr, "Couldn't read entire file\n");
        goto error;
    }

    fclose(file);
    return contents;

error:
    free(contents);
    fclose(file);
    return NULL;
}

int decode_main(const char *filename, const char *output_filename)
{
    if (!filename)
    {
        fprintf(stderr, "no input filename provided\n");
        return 1;
    }
    if (!output_filename)
    {
        fprintf(stderr, "no output filename provided\n");
        return 1;
    }

    /* decoder context */
    mp3dec_t mp3d;
    mp3dec_frame_info_t info;
    short pcm[MINIMP3_MAX_SAMPLES_PER_FRAME];

    long filesize;
    unsigned int bytes_read = 0;
    unsigned char *input_buffer;
    FILE *output_file = NULL;

    input_buffer = read_file(filename, &filesize);
    if (!input_buffer)
    {
        fprintf(stderr, "Error reading %s into buffer.\n", filename);
        goto error;
    }

    output_file = fopen(output_filename, "wb");
    if (!output_file)
    {
        fprintf(stderr, "Couldn't open output file %s.\n", output_filename);
        goto error;
    }

    // initialize decoder
    mp3dec_init(&mp3d);

    while (bytes_read < filesize)
    {
        int samples_decoded = mp3dec_decode_frame(&mp3d, input_buffer + bytes_read,
                                                  filesize - bytes_read, pcm, &info);

        if (samples_decoded > 0)
        {
            fwrite(pcm, sizeof(short), samples_decoded * info.channels, output_file);
        }
        bytes_read += info.frame_bytes;
    }

    free(input_buffer);
    fclose(output_file);

    return 0;

error:
    if (input_buffer)
    {
        free(input_buffer);
    }
    if (output_file)
    {
        fclose(output_file);
    }

    return 1;
}

#ifndef USING_ZIG
int main(int argc, char **argv)
{
    if (argc < 2)
    {
        fprintf(stderr, "Please provide a file to decode.\n");
        return 1;
    }
    if (argc < 3)
    {
        fprintf(stderr, "Please provide a filename to write to.\n");
        return 1;
    }

    return decode_main(argv[1], argv[2]);
}
#endif
