const c = struct {
    usingnamespace @cImport({
        @cInclude("minimp3.h");
    });
};

pub const max_samples_per_frame = c.MINIMP3_MAX_SAMPLES_PER_FRAME;
pub const info = c.mp3dec_frame_info_t;
pub const decoder = c.mp3dec_t;

pub extern "c" fn mp3dec_init(dec: [*c]c.mp3dec_t) void;
pub extern "c" fn mp3dec_decode_frame([*c]c.mp3dec_t, [*c]const u8, c_int, [*c]i16, [*c]c.mp3dec_frame_info_t) c_int;

pub const init = mp3dec_init;
pub const decode = mp3dec_decode_frame;
