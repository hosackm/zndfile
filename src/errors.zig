const c = @import("c.zig");
const Sndfile = @import("sndfile.zig").Sndfile;
const std = @import("std");

extern "c" fn sf_error(*c.SNDFILE) c_int;
extern "c" fn sf_strerror(*c.SNDFILE) [*c]const u8;
extern "c" fn sf_error_number(c_int) [*c]const u8;

pub const Error = error{
    UnrecognizedFormat,
    System,
    MalformedFile,
    UnsupportedEncoding,
    NonIntegerFrameSize,
    // SNDFILE uses private error codes to stay backwards
    // compatible. You can use getErrorStr to get a description
    // for an error code.
    InternalErrorCode,
};

pub fn getError(code: c_int) Error {
    const err: Error = switch (code) {
        c.SF_ERR_UNRECOGNISED_FORMAT => Error.UnrecognizedFormat,
        c.SF_ERR_SYSTEM => Error.System,
        c.SF_ERR_MALFORMED_FILE => Error.MalformedFile,
        c.SF_ERR_UNSUPPORTED_ENCODING => Error.UnsupportedEncoding,
        else => Error.InternalErrorCode,
    };
    if (err == Error.InternalErrorCode) {
        std.debug.print(
            "internal error - {s}\n",
            .{std.mem.span(sf_error_number(code))},
        );
    }
    return err;
}

pub fn throwIfError(s: *c.SNDFILE) !void {
    const code = sf_error(s);
    return switch (code) {
        c.SF_ERR_NO_ERROR => {},
        else => getError(code),
    };
}

pub fn getErrorString(s: *c.SNDFILE) []const u8 {
    return std.mem.span(sf_error_number(sf_error(s)));
}

test "get error str, no error" {
    std.debug.print("{s}", .{sf_error_number(c.SF_ERR_NO_ERROR)});
}
