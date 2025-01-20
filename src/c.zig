const c = @cImport({
    @cInclude("minimp3.h");
});

pub const init = mp3dec_init;
pub const decode = mp3dec_decode_frame;

pub const max_samples_per_frame = c.MINIMP3_MAX_SAMPLES_PER_FRAME;
pub const Info = c.mp3dec_frame_info_t;
pub const Decoder = c.mp3dec_t;

extern "c" fn mp3dec_init(dec: *Decoder) void;
extern "c" fn mp3dec_decode_frame(*Decoder, [*]const u8, c_int, [*]i16, *Info) c_int;
