const c = @import("c.zig");
const Mode = @import("zndfile.zig").Mode;

pub const Config = @This();

extern "c" fn sf_format_check(*const c.SF_INFO) c_int;

/// Used to configure the internal SNDFILE for read/write and also
/// set the format that will be used when writing.
// pub const FileConfig = struct {
mode: Mode = .read,

// if mode set to .write, you must provide the following
// values in order to configure the SF_INFO used when
// opening the sndfile for writing.
format: Format = Format.wav,
subformat: Subformat = Subformat.float,
channels: usize = 2,
samplerate: u32 = 48000,

// Checks whether the config is valid or if libsndfile will
// return an UnrecognizedFormat error code.
pub fn isValid(self: Config) bool {
    if (self.mode == .read) return true;
    return sf_format_check(&.{
        .samplerate = @intCast(self.samplerate),
        .format = self.formatBitmask(),
        .channels = @intCast(self.channels),
    }) == c.SF_TRUE;
}

pub inline fn formatBitmask(self: Config) c_int {
    return (@intFromEnum(self.format) & c.SF_FORMAT_TYPEMASK) |
        (@intFromEnum(self.subformat) & c.SF_FORMAT_SUBMASK);
}

/// Format bitmasks from sndfile.h
pub const Format = enum(i32) {
    wav = c.SF_FORMAT_WAV, // Microsoft WAV format (little endian default).
    aiff = c.SF_FORMAT_AIFF, // Apple/SGI AIFF format (big endian).
    au = c.SF_FORMAT_AU, // Sun/NeXT AU format (big endian).
    raw = c.SF_FORMAT_RAW, // RAW PCM data.
    paf = c.SF_FORMAT_PAF, // Ensoniq PARIS file format.
    svx = c.SF_FORMAT_SVX, // Amiga IFF / SVX8 / SV16 format.
    nist = c.SF_FORMAT_NIST, // Sphere NIST format.
    voc = c.SF_FORMAT_VOC, // VOC files.
    ircam = c.SF_FORMAT_IRCAM, // Berkeley/IRCAM/CARL
    w64 = c.SF_FORMAT_W64, // Sonic Foundry's 64 bit RIFF/WAV
    mat4 = c.SF_FORMAT_MAT4, // Matlab (tm) V4.2 / GNU Octave 2.0
    mat5 = c.SF_FORMAT_MAT5, // Matlab (tm) V5.0 / GNU Octave 2.1
    pvf = c.SF_FORMAT_PVF, // Portable Voice Format
    xi = c.SF_FORMAT_XI, // Fasttracker 2 Extended Instrument
    htk = c.SF_FORMAT_HTK, // HMM Tool Kit format
    sds = c.SF_FORMAT_SDS, // Midi Sample Dump Standard
    avr = c.SF_FORMAT_AVR, // Audio Visual Research
    wavex = c.SF_FORMAT_WAVEX, // MS WAVE with WAVEFORMATEX
    sd2 = c.SF_FORMAT_SD2, // Sound Designer 2
    flac = c.SF_FORMAT_FLAC, // FLAC lossless file format
    caf = c.SF_FORMAT_CAF, // Core Audio File format
    wve = c.SF_FORMAT_WVE, // Psion WVE format
    ogg = c.SF_FORMAT_OGG, // Xiph OGG container
    mpc2k = c.SF_FORMAT_MPC2K, // Akai MPC 2000 sampler
    rf64 = c.SF_FORMAT_RF64, // RF64 WAV file
    mpeg = c.SF_FORMAT_MPEG, // MPEG-1/2 audio stream
};

/// Subformat bitmasks from sndfile.h
pub const Subformat = enum(i32) {
    pcm_s8 = c.SF_FORMAT_PCM_S8, // Signed 8 bit data
    pcm_16 = c.SF_FORMAT_PCM_16, // Signed 16 bit data
    pcm_24 = c.SF_FORMAT_PCM_24, // Signed 24 bit data
    pcm_32 = c.SF_FORMAT_PCM_32, // Signed 32 bit data
    pcm_u8 = c.SF_FORMAT_PCM_U8, // Unsigned 8 bit data (WAV and RAW only)
    float = c.SF_FORMAT_FLOAT, // 32 bit float data
    double = c.SF_FORMAT_DOUBLE, // 64 bit float data
    ulaw = c.SF_FORMAT_ULAW, // U-Law encoded.
    alaw = c.SF_FORMAT_ALAW, // A-Law encoded.
    ima_adpcm = c.SF_FORMAT_IMA_ADPCM, // IMA ADPCM.
    ms_adpcm = c.SF_FORMAT_MS_ADPCM, // Microsoft ADPCM.
    gsm610 = c.SF_FORMAT_GSM610, // GSM 6.10 encoding.
    vox_adpcm = c.SF_FORMAT_VOX_ADPCM, // OKI / Dialogix ADPCM
    nms_adpcm_16 = c.SF_FORMAT_NMS_ADPCM_16, // 16kbs NMS G721-variant encoding.
    nms_adpcm_24 = c.SF_FORMAT_NMS_ADPCM_24, // 24kbs NMS G721-variant encoding.
    nms_adpcm_32 = c.SF_FORMAT_NMS_ADPCM_32, // 32kbs NMS G721-variant encoding.
    g721_32 = c.SF_FORMAT_G721_32, // 32kbs G721 ADPCM encoding.
    g723_24 = c.SF_FORMAT_G723_24, // 24kbs G723 ADPCM encoding.
    g723_40 = c.SF_FORMAT_G723_40, // 40kbs G723 ADPCM encoding.
    dwvw_12 = c.SF_FORMAT_DWVW_12, // 12 bit Delta Width Variable Word encoding.
    dwvw_16 = c.SF_FORMAT_DWVW_16, // 16 bit Delta Width Variable Word encoding.
    dwvw_24 = c.SF_FORMAT_DWVW_24, // 24 bit Delta Width Variable Word encoding.
    dwvw_n = c.SF_FORMAT_DWVW_N, // N bit Delta Width Variable Word encoding.
    dpcm_8 = c.SF_FORMAT_DPCM_8, // 8 bit differential PCM (XI only)
    dpcm_16 = c.SF_FORMAT_DPCM_16, // 16 bit differential PCM (XI only)
    vorbis = c.SF_FORMAT_VORBIS, // Xiph Vorbis encoding.
    opus = c.SF_FORMAT_OPUS, // Xiph/Skype Opus encoding.
    alac_16 = c.SF_FORMAT_ALAC_16, // Apple Lossless Audio Codec (16 bit).
    alac_20 = c.SF_FORMAT_ALAC_20, // Apple Lossless Audio Codec (20 bit).
    alac_24 = c.SF_FORMAT_ALAC_24, // Apple Lossless Audio Codec (24 bit).
    alac_32 = c.SF_FORMAT_ALAC_32, // Apple Lossless Audio Codec (32 bit).
    mpeg_layer_i = c.SF_FORMAT_MPEG_LAYER_I, // MPEG-1 Audio Layer I
    mpeg_layer_ii = c.SF_FORMAT_MPEG_LAYER_II, // MPEG-1 Audio Layer I
    mpeg_layer_iii = c.SF_FORMAT_MPEG_LAYER_III, // MPEG-2 Audio Layer III
};
