const zeroes = @import("std").mem.zeroes;

pub const mp3d_sample_t = i16;

pub const mp3dec_frame_info_t = extern struct {
    frame_bytes: c_int = zeroes(c_int),
    frame_offset: c_int = zeroes(c_int),
    channels: c_int = zeroes(c_int),
    hz: c_int = zeroes(c_int),
    layer: c_int = zeroes(c_int),
    bitrate_kbps: c_int = zeroes(c_int),
};

pub const mp3dec_t = extern struct {
    mdct_overlap: [2][288]f32 = zeroes([2][288]f32),
    qmf_state: [960]f32 = zeroes([960]f32),
    reserv: c_int = zeroes(c_int),
    free_format_bytes: c_int = zeroes(c_int),
    header: [4]u8 = zeroes([4]u8),
    reserv_buf: [511]u8 = zeroes([511]u8),
};
