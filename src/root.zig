pub usingnamespace @import("sndfile.zig");
pub usingnamespace @import("errors.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
