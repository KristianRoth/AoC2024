const std = @import("std");
const shared = @import("../shared.zig");

const HM = std.StringHashMap(usize);

fn isPrefixed(needle: []const u8, haystack: []const u8) ?[]const u8 {
    if (std.mem.startsWith(u8, haystack, needle)) {
        return haystack[needle.len..];
    }
    return null;
}

fn countWays(
    order: []const u8,
    towels: [][]const u8,
    counted: *HM,
) !usize {
    return counted.get(order) orelse blk: {
        var count: usize = 0;
        for (towels) |towel| {
            if (isPrefixed(towel, order)) |rest| {
                if (rest.len == 0) {
                    count += 1;
                    continue;
                }
                count += try countWays(rest, towels, counted);
            }
        }
        try counted.put(order, count);
        break :blk count;
    };
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc19/input.txt", allocator);
    var counted = HM.init(allocator);
    const towels = try shared.splitCharSlice(input[0], ", ");
    const orders = input[2..];
    var sum: usize = 0;
    var sum2: usize = 0;
    for (orders) |order| {
        const count = try countWays(order, towels, &counted);
        if (count > 0) {
            sum += 1;
        }
        sum2 += count;
    }

    std.debug.print("Day 19 Part 1: {}\n", .{sum});
    std.debug.print("Day 19 Part 2: {}\n", .{sum2});
}
