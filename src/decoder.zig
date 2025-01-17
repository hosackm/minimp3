const c = @import("c.zig");
const Self = @This();

ptr: c.decoder = null,
ready: bool = false,

// Store pcm and info from last decoded frame
var pcm: [c.max_samples_per_frame]i16 = undefined;
var info: c.info = undefined;

inline fn init(self: *Self) void {
    self.ready = true;
    c.init(&self.ptr);
}

// Add bytes to decoder and return a Result
pub fn decode(self: *Self, b: []const u8) Result {
    if (!self.ready) self.init();
    const num_frames = c.decode(&self.ptr, b.ptr, @intCast(b.len), &pcm, &info);

    return .{
        .output = prepareBuffer(num_frames),
        .info = Info.convert(info),
    };
}

// Get a buffer to return to the user
fn prepareBuffer(n: c_int) SampleBuffer {
    const num_samples: usize = @intCast(n * info.channels);
    const num_bytes: usize = @intCast(n * info.channels * @sizeOf(i16));
    return .{
        .samples = pcm[0..num_samples],
        .bytes = @as(
            [*]const u8,
            @ptrCast(pcm[0..]),
        )[0..num_bytes],
        .channels = @intCast(info.channels),
    };
}

// Result contains the information about the frame decoded
// as well as an output sample buffer if one was provided
pub const Result = struct {
    output: ?SampleBuffer,
    info: Info,
};

// SampleBuffer is returned to the user
pub const SampleBuffer = struct {
    samples: []i16 = undefined,
    bytes: []const u8 = undefined,
    channels: usize = undefined,
};

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
