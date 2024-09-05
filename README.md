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

There is an example provided in the `example` directory.

You can copy this code directly into your `src/main.zig`.

### Run the example

An `example.mp3` is provided in the example directory. You can decode it using:

```bash
zig build run -- example.mp3 output.pcm
```

### Test the example

The example writes an audio file as raw pcm. Use `ffplay` to play it:

> **Note**: _At the time of writing the current major version of `ffmpeg` is 7. The options I'm providing may not work for your version of `ffplay`._

```bash
ffplay -f s16le -ch_layout stereo -sample_rate 44100 output.pcm
```
