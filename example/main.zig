const std = @import("std");
const mp3 = @import("minimp3");

const usage: []const u8 = "Usage: {s} <input> <output>\n";

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 3) {
        std.debug.print(usage, .{std.fs.path.basename(args[0])});
        return;
    }

    const f = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer f.close();

    const output_file = try std.fs.cwd().createFile(args[2], .{});
    defer output_file.close();

    const bytes = try f.readToEndAlloc(alloc, 1000000000);

    var decoder: mp3.Decoder = undefined;
    decoder.init();

    var i: usize = 0;
    var num_samples: usize = 0;
    while (i < bytes.len) {
        const frame = decoder.decode(bytes[i..]);
        if (frame.output) |buffer| {
            num_samples += try output_file.write(buffer.bytes);
        }
        i += frame.info.frame_bytes;
    }

    std.debug.print("Wrote {d} samples to {s}\n", .{ num_samples, args[2] });
}
