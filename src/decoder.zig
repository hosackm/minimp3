const std = @import("std");
const c = @import("c.zig");

// Encapsulates the info about the decoded frame
pub const Info = struct {
    frame_bytes: usize,
    frame_offset: usize,
    channels: u2,
    hz: u32,
    layer: u4,
    bitrate: u32,

    // Converts c type to zig max_samples_per_frame
    pub fn convert(old: c.info) Info {
        return .{
            .frame_bytes = @intCast(old.frame_bytes),
            .frame_offset = @intCast(old.frame_offset),
            .channels = @intCast(old.channels),
            .hz = @intCast(old.hz),
            .layer = @intCast(old.layer),
            .bitrate = @intCast(old.bitrate_kbps),
        };
    }
};

pub const Result = struct {
    samples: []i16,
    info: Info,
};

pub const Decoder = struct {
    pcm: [c.max_samples_per_frame]i16,
    input_buffer: []u8,
    num_bytes: usize,
    ptr: c.decoder,

    pub fn init(alloc: std.mem.Allocator) !Decoder {
        var sd: Decoder = .{
            .pcm = undefined,
            .input_buffer = try alloc.alloc(u8, 2048),
            .num_bytes = 0,
            .ptr = undefined,
        };
        c.init(&sd.ptr);
        return sd;
    }

    pub fn deinit(self: *Decoder, alloc: std.mem.Allocator) void {
        alloc.free(self.input_buffer);
    }

    pub fn nextFrame(self: *Decoder, rdr: anytype) !?Result {
        const n = try rdr.read(self.input_buffer[self.num_bytes..]);
        self.num_bytes += n;

        var local_info: c.info = undefined;
        const num_frames = c.decode(
            &self.ptr,
            self.input_buffer.ptr,
            @intCast(self.num_bytes),
            &self.pcm,
            &local_info,
        );
        if (num_frames == 0) {
            return null;
        }

        // move the buffer to front
        const bytes_consumed: usize = @intCast(local_info.frame_bytes);
        std.mem.copyForwards(
            u8,
            self.input_buffer,
            self.input_buffer[bytes_consumed..],
        );
        self.num_bytes -= bytes_consumed;

        const num_samples: usize = @intCast(num_frames * local_info.channels);
        return .{
            .samples = self.pcm[0..num_samples],
            .info = Info.convert(local_info),
        };
    }
};
