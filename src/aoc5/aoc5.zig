const std = @import("std");
const shared = @import("../shared.zig");

fn isCorrect(nums: [][]const u8, isAfter: *std.StringHashMap(bool)) !bool {
    var buffer: [5]u8 = undefined; // Adjust size as needed

    for (nums, 0..) |num1, i| {
        for (nums[i + 1 ..], (i + 1)..) |num2, j| {
            //std.debug.print("{s} {s}\n", .{ num1, num2 });
            _ = try std.fmt.bufPrint(buffer[0..], "{s}|{s}", .{ num2, num1 });
            if (isAfter.get(&buffer) orelse false) {
                const temp = nums[i];
                nums[i] = nums[j];
                nums[j] = temp;
                return false;
            }
        }
    }
    return true;
}

fn fixNums(nums: [][]const u8, isAfter: *std.StringHashMap(bool)) !void {
    while (!try isCorrect(nums, isAfter)) {}
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const chars = try shared.readToCharSlice("src/aoc5/input.txt", allocator);

    var isAfter = std.StringHashMap(bool).init(allocator);
    var endOfDecl: usize = 0;
    for (chars, 0..) |line, i| {
        if (line.len == 0) {
            endOfDecl = i + 1;
            break;
        }
        try isAfter.put(line, true);
    }
    var sum: u32 = 0;
    var fixedSum: u32 = 0;
    for (chars[endOfDecl..]) |line| {
        const nums = try shared.splitCharSlice(line, ",");
        if (try isCorrect(nums, &isAfter)) {
            sum += try std.fmt.parseInt(u32, nums[(nums.len - 1) / 2], 10);
        } else {
            try fixNums(nums, &isAfter);
            fixedSum += try std.fmt.parseInt(u32, nums[(nums.len - 1) / 2], 10);
        }
    }
    std.debug.print("Day 5 Part 1: {}\n", .{sum});
    std.debug.print("Day 5 Part 2: {}\n", .{fixedSum});
}
