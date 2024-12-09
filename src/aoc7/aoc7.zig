const std = @import("std");
const shared = @import("../shared.zig");

const buffer_size = 128;
var global_buffer: [buffer_size]u8 = undefined;

fn catExact(number: i64, digits: i64) !i64 {
    const number_str = global_buffer[0..];
    const digits_str = global_buffer[64..];

    const num = try std.fmt.bufPrint(number_str, "{d}", .{number});
    const end = try std.fmt.bufPrint(digits_str, "{d}", .{digits});

    if (std.mem.endsWith(u8, num, end)) {
        return try std.fmt.parseInt(i64, num[0 .. num.len - end.len], 10);
    }
    return error.NotFound;
}

fn findSolWithCat(target: i64, nums: []const i64) bool {
    if (target == 0) {
        return true;
    }
    if (nums.len == 0) {
        return false;
    }
    if (target < 0) {
        return false;
    }
    if (catExact(target, nums[nums.len - 1])) |new_target| {
        if (findSolWithCat(new_target, nums[0 .. nums.len - 1])) {
            return true;
        }
    } else |_| {}

    if (std.math.divExact(i64, target, nums[nums.len - 1])) |new_target| {
        if (findSolWithCat(new_target, nums[0 .. nums.len - 1])) {
            return true;
        }
    } else |_| {}

    return findSolWithCat(target - nums[nums.len - 1], nums[0 .. nums.len - 1]);
}

fn findSol(target: i64, nums: []const i64) bool {
    if (target == 0) {
        return true;
    }
    if (nums.len == 0) {
        return false;
    }
    if (target < 0) {
        return false;
    }
    if (std.math.divExact(i64, target, nums[nums.len - 1])) |new_target| {
        return findSol(target - nums[nums.len - 1], nums[0 .. nums.len - 1]) or findSol(new_target, nums[0 .. nums.len - 1]);
    } else |_| {
        return findSol(target - nums[nums.len - 1], nums[0 .. nums.len - 1]);
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc7/input.txt", allocator);
    defer allocator.free(input);
    var sum: i64 = 0;
    var sumWithCat: i64 = 0;
    for (input) |line| {
        const vals = try shared.splitCharSlice(line, ": ");
        const target = try std.fmt.parseInt(i64, vals[0], 10);
        const nums_as_str = try shared.splitCharSlice(vals[1], " ");
        const nums = try allocator.alloc(i64, nums_as_str.len);
        defer allocator.free(nums);
        for (nums_as_str, 0..) |num_str, i| {
            const num = try std.fmt.parseInt(i64, num_str, 10);
            nums[i] = num;
        }
        if (findSol(target, nums)) {
            sum += target;
        }
        if (findSolWithCat(target, nums)) {
            sumWithCat += target;
        }
    }
    std.debug.print("Day 7 Part 1: {}\n", .{sum});
    std.debug.print("Day 7 Part 2: {}\n", .{sumWithCat});
}
