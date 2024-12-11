const std = @import("std");
const shared = @import("../shared.zig");

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc11/input.txt", allocator);
    const numsStrs = try shared.splitCharSlice(input[0], " ");
    var nums = std.AutoHashMap(u128, u128).init(allocator);
    var nextNums = std.AutoHashMap(u128, u128).init(allocator);
    const buf = try allocator.alloc(u8, 100);
    for (numsStrs) |numStr| {
        const num = try std.fmt.parseInt(u128, numStr, 10);
        try nums.put(num, 1);
    }

    var sum: u128 = 0;
    for (0..75) |i| {
        if (i == 25) {
            var iter = nums.valueIterator();
            while (iter.next()) |entry| {
                sum += entry.*;
            }
        }
        var iter = nums.iterator();
        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const numStr = try std.fmt.bufPrint(buf, "{d}", .{key});
            if (key == 0) {
                if (nextNums.get(1)) |value| {
                    try nextNums.put(1, value + entry.value_ptr.*);
                } else {
                    try nextNums.put(1, entry.value_ptr.*);
                }
            } else if (numStr.len % 2 == 0) {
                const newNum1 = try std.fmt.parseInt(u128, numStr[0 .. numStr.len / 2], 10);
                const newNum2 = try std.fmt.parseInt(u128, numStr[numStr.len / 2 ..], 10);
                if (nextNums.get(newNum1)) |value| {
                    try nextNums.put(newNum1, value + entry.value_ptr.*);
                } else {
                    try nextNums.put(newNum1, entry.value_ptr.*);
                }
                if (nextNums.get(newNum2)) |value| {
                    try nextNums.put(newNum2, value + entry.value_ptr.*);
                } else {
                    try nextNums.put(newNum2, entry.value_ptr.*);
                }
            } else {
                const newNum = entry.key_ptr.* * 2024;
                if (nextNums.get(newNum)) |value| {
                    try nextNums.put(newNum, value + entry.value_ptr.*);
                } else {
                    try nextNums.put(newNum, entry.value_ptr.*);
                }
            }
        }
        nums.clearRetainingCapacity();
        const temp = nums;
        nums = nextNums;
        nextNums = temp;
    }

    var sum2: u128 = 0;
    var iter2 = nums.valueIterator();
    while (iter2.next()) |entry| {
        sum2 += entry.*;
    }

    std.debug.print("Day 11 Part 1: {d}\n", .{sum});
    std.debug.print("Day 11 Part 2: {d}\n", .{sum2});
}
