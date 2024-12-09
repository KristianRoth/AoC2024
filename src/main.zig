const std = @import("std");
const aoc1 = @import("aoc1/aoc1.zig");
const aoc2 = @import("aoc2/aoc2.zig");
const aoc3 = @import("aoc3/aoc3.zig");
const aoc4 = @import("aoc4/aoc4.zig");
const aoc5 = @import("aoc5/aoc5.zig");
const aoc6 = @import("aoc6/aoc6.zig");
const aoc7 = @import("aoc7/aoc7.zig");

pub fn main() !void {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch return;
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <day> [--time]\n", .{args[0]});
        return;
    }

    const day = try std.fmt.parseInt(u8, args[1], 10);
    const measure_time = args.len > 2 and std.mem.eql(u8, args[2], "--time");

    var start_time: i128 = 0;
    if (measure_time) {
        start_time = std.time.nanoTimestamp();
    }

    switch (day) {
        1 => try aoc1.solve(),
        2 => try aoc2.solve(),
        3 => try aoc3.solve(),
        4 => try aoc4.solve(),
        5 => try aoc5.solve(),
        6 => try aoc6.solve(),
        7 => try aoc7.solve(),
        else => {
            std.debug.print("Day {d} not implemented\n", .{day});
            return;
        },
    }

    if (measure_time) {
        const end_time = std.time.nanoTimestamp();
        const duration = end_time - start_time;
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{d}\n", .{duration});
    }
}
