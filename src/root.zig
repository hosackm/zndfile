pub usingnamespace @import("zndfile.zig");
pub usingnamespace @import("errors.zig");
pub usingnamespace @import("config.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
