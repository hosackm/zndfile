//! This file shows how the zndfile module can be used to read
//! a sound file and write the contents to another sound file.
const std = @import("std");
const znd = @import("zndfile");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    defer if (gpa.deinit() == .leak) std.debug.print("Memory leaked!\n", .{});

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 3) {
        return error.NotEnoughArguments;
    }

    // Try changing this to i32, f32, f64
    const T = i16;
    var input_file = try znd.Sndfile.init(args[1], .{});
    defer input_file.deinit();

    // Open the output file as a 16-bit signed WAV
    var output_file = try znd.Sndfile.init(args[2], .{ .mode = .write, .subformat = .pcm_16 });
    defer output_file.deinit();

    const frame_size = 128;
    const samples_per_frame: usize = input_file.info.channels;
    const items_per_buffer = frame_size * samples_per_frame;

    // create a buffer to hold our samples
    const buffer = try alloc.alloc(T, items_per_buffer);
    defer alloc.free(buffer);

    while (true) {
        // The bit-depth of the input file does not have to match the
        // request read type (T) and the write type (T) does not have
        // to match the bit-depth of the output file.

        // read from input file
        const num_frames_read = try input_file.read(T, buffer);
        if (num_frames_read == 0) break;

        // do something with the samples
        for (0..num_frames_read) |i| {
            buffer[i] = @divTrunc(buffer[i], 2);
        }

        // write to output file
        // libsndfile will handle writing the 32-bit samples
        // as 16-bit in the output file.
        _ = try output_file.write(
            T,
            buffer[0..num_frames_read],
        );
    }
}
