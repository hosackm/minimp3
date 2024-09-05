pub const max_sample_per_frame = 1152 * 2;

pub const MiniMp3FrameInfo = extern struct {
    frame_bytes: c_int,
    frame_offset: c_int,
    channels: c_int,
    hz: c_int,
    layer: c_int,
    bitrate_kbps: c_int,
};

pub const MiniMp3Decoder = extern struct {
    mdct_overlap: [2][288]f32,
    qmf_state: [960]f32,
    reserv: c_int,
    free_format_bytes: c_int,
    header: [4]u8,
    reserv_buf: [511]u8,
};

pub extern "c" fn mp3dec_init(dec: [*c]MiniMp3Decoder) void;
pub extern "c" fn mp3dec_decode_frame(
    dec: [*c]MiniMp3Decoder,
    mp3: [*c]const u8,
    mp3_bytes: c_int,
    pcm: [*c]i16,
    info: [*c]MiniMp3FrameInfo,
) c_int;
