# minimp3

[zig](https://ziglang.org) bindings for [minimp3](https://github.com/lieff/minimp3).

> **NOTE:** This project is based on [zig](https://ziglang.org/documentation/0.13.0/) version 0.13.0. Other versions of zig are not guaranteed to work and may require modifications.

## Install it

First, run:

```bash
zig fetch --save git+https://github.com/hosackm/minimp3
```

Next, update your `build.zig`:

```zig
const minimp3 = b.dependency("minimp3", .{});
exe.root_module.addImport("minimp3", minimp3.module("minimp3"));
```

## Example

There is an example provided in `example/main.zig` for reading from an mp3 and writing to a raw pcm file.

You can copy this code directly into your `src/main.zig`.

### Run the example

In the test folder you'll find two example mp3s. These can be decoded with the application by running:

```bash
zig build run -- test/example.mp3 test/output.pcm
```

### Test the example

In order to play the file you can use `ffplay`.

> **Note**: _At the time of writing the current major version of `ffmpeg` is 7. The options I'm providing may not work for your version of `ffplay`._

```bash
ffplay -f s16le -ch_layout stereo -sample_rate 44100 test/output.pcm
```
