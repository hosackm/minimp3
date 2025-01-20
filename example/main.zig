const std = @import("std");
const Decoder = @import("decoder");

const usage: []const u8 = "Usage: {s} <input> <output>\n";

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const input_file = try std.fs.cwd().openFile(
        args[1],
        .{ .mode = .read_only },
    );
    defer input_file.close();

    const output_file = try std.fs.cwd().createFile(
        args[2],
        .{},
    );
    defer output_file.close();

    var buffer: [4096]u8 = undefined;
    var falloc = std.heap.FixedBufferAllocator.init(&buffer);
    var sd = try Decoder.Decoder.init(falloc.allocator());

    defer sd.deinit(falloc.allocator());
    while (try sd.nextFrame(input_file.reader())) |frame| {
        _ = try output_file.write(std.mem.sliceAsBytes(frame.samples));
        std.debug.print(
            "Wrote {d} bytes to {d} samples.\n",
            .{ frame.info.frame_bytes, frame.samples.len },
        );
    }
}
