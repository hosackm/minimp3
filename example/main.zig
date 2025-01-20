const std = @import("std");
const Decoder = @import("decoder");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const stdout = std.io.getStdOut();
    var output_buffer: [256]u8 = undefined;

    if (args.len < 3) {
        _ = try stdout.write(try std.fmt.bufPrint(
            &output_buffer,
            "Usage: {s} <input> <output>\n",
            .{args[0]},
        ));
        std.process.exit(1);
        return;
    }

    const input_file = try std.fs.cwd().openFile(args[1], .{});
    defer input_file.close();
    const rdr = input_file.reader();

    const output_file = try std.fs.cwd().createFile(args[2], .{});
    defer output_file.close();

    var dec = Decoder.init();
    var total_frames: usize = 0;
    var bitrate_acc: usize = 0;
    while (try dec.nextFrame(rdr)) |frame| : (total_frames += 1) {
        _ = try output_file.write(std.mem.sliceAsBytes(frame.samples));
        bitrate_acc += frame.info.bitrate;

        _ = try stdout.write(try std.fmt.bufPrint(
            &output_buffer,
            "Wrote {d} bytes->{d} samples. [{d} ch, {d} Hz, layer-{d}, bitrate: {d} kbps]\n",
            .{
                frame.info.frame_bytes,
                frame.samples.len,
                frame.info.channels,
                frame.info.hz,
                frame.info.layer,
                frame.info.bitrate,
            },
        ));
    }

    // print some stats about what was decoded
    _ = try stdout.write(try std.fmt.bufPrint(
        &output_buffer,
        "Processed {d} total frames with an average bitrate of {d} kbps.\n",
        .{
            total_frames,
            @divFloor(bitrate_acc, total_frames),
        },
    ));
}
