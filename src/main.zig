const std = @import("std");

extern fn decode_main(filename: [*c]c_char, output_filename: [*c]c_char) c_int;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 3) {
        std.debug.print("more args please\n", .{});
        return;
    }
    if (args.len < 2) {
        std.debug.print("Please provide a file to decode.\n", .{});
        return;
    }
    if (args.len < 3) {
        std.debug.print("Please provide a filename to write to.\n", .{});
        return;
    }

    _ = decode_main(@ptrCast(args[1]), @ptrCast(args[2]));
}
