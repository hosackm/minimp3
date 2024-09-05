const std = @import("std");

const mp3 = @import("wrap.zig");
const MiniMp3Decoder = mp3.MiniMp3Decoder;
const MiniMp3FrameInfo = mp3.MiniMp3FrameInfo;

pub const Decoder = struct {
    instance: MiniMp3Decoder = undefined,

    const Self = @This();
    var pcm: [mp3.max_sample_per_frame]i16 = undefined;
    var info: MiniMp3FrameInfo = undefined;

    pub fn init(self: *Self) void {
        mp3.mp3dec_init(&self.instance);
    }

    // Add bytes to decoder and return a DecodeResult
    pub fn decode(self: *Self, bytes: []const u8) DecodeResult {
        const num_frames = mp3.mp3dec_decode_frame(
            &self.instance,
            @constCast(@ptrCast(bytes.ptr)),
            @intCast(bytes.len),
            &pcm,
            @ptrCast(&info),
        );

        return .{
            .output = prepareBuffer(num_frames),
            .info = FrameInfo.convert(info),
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
};

// DecodeResult contains the information about the frame decoded
// as well as an output sample buffer if one was provided
pub const DecodeResult = struct {
    output: ?SampleBuffer,
    info: FrameInfo,
};

// SampleBuffer is returned to the user
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

    // Converts c type to zig type
    pub fn convert(old: MiniMp3FrameInfo) FrameInfo {
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
