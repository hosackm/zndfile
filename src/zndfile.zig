const std = @import("std");
const c = @import("c.zig");
const Config = @import("config.zig");

const errors = @import("errors.zig");
const ZndError = errors.ZndError;
const throwIfError = errors.throwIfError;

/// Functions defined and linked by libsndfile.
extern "c" fn sf_open([*]const u8, c_int, *c.SF_INFO) *c.SNDFILE;
extern "c" fn sf_close(*c.SNDFILE) void;
extern "c" fn sf_write_sync(*c.SNDFILE) void;
extern "c" fn sf_read_short(*c.SNDFILE, [*]i16, i64) i64;
extern "c" fn sf_read_int(*c.SNDFILE, [*]i32, i64) i64;
extern "c" fn sf_read_float(*c.SNDFILE, [*]f32, i64) i64;
extern "c" fn sf_read_double(*c.SNDFILE, [*]f64, i64) i64;
extern "c" fn sf_write_short(*c.SNDFILE, [*]const i16, i64) i64;
extern "c" fn sf_write_int(*c.SNDFILE, [*]const i32, i64) i64;
extern "c" fn sf_write_float(*c.SNDFILE, [*]const f32, i64) i64;
extern "c" fn sf_write_double(*c.SNDFILE, [*]const f64, i64) i64;

/// Struct exported by this module
pub const Zndfile = @This();

/// Mode in which to open the file.
pub const Mode = enum(u8) {
    read = c.SFM_READ,
    write = c.SFM_WRITE,
    read_write = c.SFM_RDWR,
};

/// Information about the
pub const Info = struct {
    frames: i64,
    samplerate: u32,
    channels: u8,
    format: i32,
    sections: i32,
    seekable: i32,
};

file: *c.SNDFILE = undefined,
info: Info = undefined,
cfg: Config = undefined,

/// Initialize a SNDFILE object
pub fn init(filename: []const u8, cfg: Config) ZndError!Zndfile {
    if (!cfg.isValid()) {
        return ZndError.UnrecognizedFormat;
    }

    var info: c.SF_INFO = .{
        .samplerate = @intCast(cfg.samplerate),
        .format = cfg.formatBitmask(),
        .channels = @intCast(cfg.channels),
    };
    const file = sf_open(
        filename.ptr,
        @intFromEnum(cfg.mode),
        &info,
    );

    try throwIfError(file);

    return .{
        .cfg = cfg,
        .file = file,
        .info = .{
            .frames = info.frames,
            .samplerate = @intCast(info.samplerate),
            .channels = @intCast(info.channels),
            .format = info.format,
            .sections = info.sections,
            .seekable = info.seekable,
        },
    };
}

pub fn deinit(self: *Zndfile) void {
    _ = sf_close(self.file);
}

/// Read samples from Zndfile into buffer. Returns number of bytes
/// read from the file which can be less than the buffer provided.
pub fn read(self: Zndfile, T: type, b: []T) ZndError!usize {
    const read_fn = switch (T) {
        i16 => c.sf_read_short,
        i32 => c.sf_read_int,
        f32 => c.sf_read_float,
        f64 => c.sf_read_double,
        else => @compileError("T must be one of: i16, i32, f32, f64."),
    };

    const num_read: usize = @intCast(read_fn(self.file, b.ptr, @intCast(b.len)));
    try throwIfError(self.file);
    return num_read;
}

/// Write samples to Zndfile from the provided buffer. Returns the number
/// of samples that were written. The buffer is assumed to contain interleaved
/// samples.
pub fn write(self: Zndfile, T: type, b: []const T) ZndError!usize {
    const write_fn = switch (T) {
        i16 => sf_write_short,
        i32 => sf_write_int,
        f32 => sf_write_float,
        f64 => sf_write_double,
        else => @compileError("T must be one of: i16, i32, f32, f64."),
    };

    const num_written: usize = @intCast(write_fn(self.file, b.ptr, @intCast(b.len)));
    try throwIfError(self.file);
    return num_written;
}
