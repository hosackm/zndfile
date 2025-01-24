const c = @import("c.zig");
const Zndfile = @import("zndfile.zig").Zndfile;
const std = @import("std");

extern "c" fn sf_error(*c.SNDFILE) c_int;
extern "c" fn sf_strerror(*c.SNDFILE) [*c]const u8;
extern "c" fn sf_error_number(c_int) [*c]const u8;

pub const ZndError = error{
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

pub fn getError(code: c_int) ZndError {
    const err: ZndError = switch (code) {
        c.SF_ERR_UNRECOGNISED_FORMAT => ZndError.UnrecognizedFormat,
        c.SF_ERR_SYSTEM => ZndError.System,
        c.SF_ERR_MALFORMED_FILE => ZndError.MalformedFile,
        c.SF_ERR_UNSUPPORTED_ENCODING => ZndError.UnsupportedEncoding,
        else => ZndError.InternalErrorCode,
    };
    return err;
}

pub fn throwIfError(s: *c.SNDFILE) ZndError!void {
    const code = sf_error(s);
    return switch (code) {
        c.SF_ERR_NO_ERROR => {},
        else => getError(code),
    };
}

pub fn getErrorString(s: *c.SNDFILE) []const u8 {
    return std.mem.span(sf_error_number(sf_error(s)));
}

test "getErrorString, no error returned through c api" {
    var s = try Zndfile.init("test-output.wav", .{ .mode = .write });
    defer {
        s.deinit();
        std.fs.cwd().deleteFile("test-output.wav") catch unreachable;
    }
    try std.testing.expect(std.mem.eql(u8, "No Error.", getErrorString(s.file)));
}
