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
    var input_file = try znd.Zndfile.init(args[1], .{});
    defer input_file.deinit();

    // Open the output file as a 16-bit signed WAV
    const output_cfg: znd.Config = .{
        .mode = .write,
        .format = .wav,
        .subformat = .pcm_16,
    };
    var output_file = try znd.Zndfile.init(args[2], output_cfg);
    defer output_file.deinit();
    // Try writing to some other formats, for example:
    // .{
    //     .mode = .write,
    //     .format = .aiff,
    //     .subformat = .pcm_16,
    // };
    // .{
    //     .mode = .write,
    //     .format = .flac,
    //     .subformat = .pcm_24,
    // };

    // On frames vs. items:
    // sndfile uses the concept of "frames" and "items" when reading
    // and/or writing to a sndfile.
    //
    // A "frame" is a grouping of samples (one for each channel of audio)
    // that are intended to be played at the same time. A frame of stereo
    // .pcm_16 audio would be an array of two 16-bit integers.
    //
    // An "item" is a single sample of audio. A frame of stereo .pcm_16
    // audio contains two "items".
    //
    // The zndfile API does it's reads and writes using items. The caller
    // passes in a slice and the number of items can easily be inferred
    // easily by using slice.len.

    // Lets create a buffer with a frame size of 128 (256 items).
    const items_per_frame: usize = input_file.info.channels;
    const num_items = 128 * items_per_frame;
    const buffer = try alloc.alloc(T, num_items);
    defer alloc.free(buffer);

    while (true) {
        // The bit-depth of the input file does not have to match the
        // request read type (T) and the write type (T) does not have
        // to match the bit-depth of the output file.

        // read from input file
        const n = try input_file.read(T, buffer);
        if (n == 0) break;

        // do something with the samples
        for (0..n) |i| {
            buffer[i] = @divTrunc(buffer[i], 2);
        }

        // write to output file
        // libsndfile will handle writing the 32-bit samples
        // as 16-bit in the output file.
        _ = try output_file.write(
            T,
            buffer[0..n],
        );
    }
}
