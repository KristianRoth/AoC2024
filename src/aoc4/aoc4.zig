const std = @import("std");
const shared = @import("../shared.zig");
const testing = @import("testing");

fn isXmas(chars: [][]const u8, x: usize, y: usize) u64 {
    const width = chars[0].len;
    const height = chars.len;
    if (chars[y][x] != 'X') {
        return 0;
    }
    var count: u64 = 0;
    if (x + 3 < width) {
        if (chars[y][x + 1] == 'M' and chars[y][x + 2] == 'A' and chars[y][x + 3] == 'S') {
            count += 1;
        }
    }
    if (x >= 3) {
        if (chars[y][x - 1] == 'M' and chars[y][x - 2] == 'A' and chars[y][x - 3] == 'S') {
            count += 1;
        }
    }
    if (y + 3 < height) {
        if (chars[y + 1][x] == 'M' and chars[y + 2][x] == 'A' and chars[y + 3][x] == 'S') {
            count += 1;
        }
    }
    if (y >= 3) {
        if (chars[y - 1][x] == 'M' and chars[y - 2][x] == 'A' and chars[y - 3][x] == 'S') {
            count += 1;
        }
    }
    if (x + 3 < width and y + 3 < height) {
        if (chars[y + 1][x + 1] == 'M' and chars[y + 2][x + 2] == 'A' and chars[y + 3][x + 3] == 'S') {
            count += 1;
        }
    }
    if (x >= 3 and y >= 3) {
        if (chars[y - 1][x - 1] == 'M' and chars[y - 2][x - 2] == 'A' and chars[y - 3][x - 3] == 'S') {
            count += 1;
        }
    }
    if (x >= 3 and y + 3 < height) {
        if (chars[y + 1][x - 1] == 'M' and chars[y + 2][x - 2] == 'A' and chars[y + 3][x - 3] == 'S') {
            count += 1;
        }
    }
    if (x + 3 < width and y >= 3) {
        if (chars[y - 1][x + 1] == 'M' and chars[y - 2][x + 2] == 'A' and chars[y - 3][x + 3] == 'S') {
            count += 1;
        }
    }
    return count;
}

fn isExMas(chars: [][]const u8, x: usize, y: usize) u64 {
    const width = chars[0].len;
    const height = chars.len;
    if (chars[y][x] != 'A') {
        return 0;
    }
    if (x >= 1 and x + 1 < width and y >= 1 and y + 1 < height) {
        if ((chars[y - 1][x - 1] == 'M' or chars[y - 1][x - 1] == 'S') and
            (chars[y + 1][x + 1] == 'M' or chars[y + 1][x + 1] == 'S') and
            chars[y - 1][x - 1] != chars[y + 1][x + 1] and
            (chars[y - 1][x + 1] == 'M' or chars[y - 1][x + 1] == 'S') and
            (chars[y + 1][x - 1] == 'M' or chars[y + 1][x - 1] == 'S') and
            chars[y - 1][x + 1] != chars[y + 1][x - 1])
        {
            return 1;
        }
    }
    return 0;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const chars = try shared.readToCharSlice("src/aoc4/input.txt", allocator);
    var countXmas: u64 = 0;
    var countExMas: u64 = 0;
    for (chars, 0..) |line, y| {
        for (line, 0..) |_, x| {
            countXmas += isXmas(chars, x, y);
            countExMas += isExMas(chars, x, y);
        }
    }
    std.debug.print("Day 4 Part 1: {}\n", .{countXmas});
    std.debug.print("Day 4 Part 2: {}\n", .{countExMas});
}
