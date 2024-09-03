# mp3decoder

This is an example mp3 decoder application that can be used to decode mp3 files into raw pcm. It is based on [minimp3](https://github.com/lieff/minimp3). The intent is to have this application serve as a baseline reference for writing an mp3 decoder in [zig](https://ziglang.org).

## Dependencies

This project relies on the [minimp3](https://github.com/lieff/minimp3) decoder. It is included as a header-only library as a git submodule that you can checkout with:

```bash
git submodule update --init --recursive
```

## Build it

`cmake` can be used to build the project. It will also generate `compile_commands.json` to be used by `clangd` if you have it installed.

To build in release:
```bash
mkdir build
cd build
cmake ..
cmake --build .
```

To build in debug:
```bash
cd build
cmake -DCMAKE_BUILD_TYPE=debug ..
cmake --build .
```

## Run it

In the test folder you'll find two example mp3s. These can be decoded with the application by running:

```bash
./mp3decode test/example.mp3 test/output.pcm
```

In order to play the file you can use `ffplay`.

> **Note**: _At the time of writing the current major version of `ffmpeg` is 7. The options I'm providing may not work for your version of `ffplay`._

```bash
ffplay -f s16le -ch_layout stereo -sample_rate 44100 test/output.pcm
```
