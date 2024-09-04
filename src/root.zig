const std = @import("std");
const t = @import("types.zig");

pub const Decoder = struct {
    instance: t.mp3dec_t = undefined,
    ptr: [*c]t.mp3dec_t = undefined,

    const Self = @This();

    const max_samples = 1152;
    const max_channels = 2;
    var pcm: [max_samples * max_channels]t.mp3d_sample_t = undefined;
    var pcm_bytes: [*]const u8 = @ptrCast(pcm[0..]);

    pub fn init(self: *Self) void {
        self.ptr = @constCast(@ptrCast(&self.instance));
        mp3dec_init(self.ptr);
    }

    // Add bytes to decdoer and return a DecodeResult
    pub fn decode(self: *Self, bytes: []const u8) DecodeResult {
        var info: t.mp3dec_frame_info_t = undefined;

        const num_frames = mp3dec_decode_frame(
            self.ptr,
            @constCast(@ptrCast(bytes.ptr)),
            @intCast(bytes.len),
            &pcm,
            @ptrCast(&info),
        );

        return .{
            .output = prepareBuffer(info, num_frames),
            .info = FrameInfo.convert(info),
        };
    }

    // Get a buffer to return to the user
    fn prepareBuffer(info: t.mp3dec_frame_info_t, n: c_int) SampleBuffer {
        const num_samples: usize = @intCast(n * info.channels);
        const num_bytes: usize = @intCast(num_samples * @sizeOf(i16));
        const pcm_bytes_slice: []const u8 = pcm_bytes[0..num_bytes];
        return .{
            .samples = pcm[0..num_samples],
            .bytes = pcm_bytes_slice,
            .channels = @intCast(info.channels),
        };
    }
};

// DecodeResult contains the information about the frame decoded
// as well as an output sample buffer if one was provided
pub const DecodeResult = struct {
    output: ?SampleBuffer,
    info: FrameInfo,
};

// SampleBuffer gives us access to samples
pub const SampleBuffer = struct {
    samples: []i16 = undefined,
    bytes: []const u8 = undefined,
    channels: usize = undefined,
};

// FrameInfo encapsulates the info about the decoded frame
pub const FrameInfo = struct {
    frame_bytes: usize,
    frame_offset: usize,
    channels: u2,
    hz: u32,
    layer: u4,
    bitrate: u32,

    const Self = @This();

    // Converts c type to zig type
    pub fn convert(old: t.mp3dec_frame_info_t) Self {
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

pub extern "c" fn mp3dec_init(dec: [*c]t.mp3dec_t) void;
pub extern "c" fn mp3dec_decode_frame(
    dec: [*c]t.mp3dec_t,
    mp3: [*c]const u8,
    mp3_bytes: c_int,
    pcm: [*c]t.mp3d_sample_t,
    info: [*c]t.mp3dec_frame_info_t,
) c_int;
