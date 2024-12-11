const std = @import("std");
const shared = @import("../shared.zig");

fn calcEnds(input: [][]const u8, visited: []bool, x: usize, y: usize) u64 {
    if (visited[y * input.len + x]) {
        return 0;
    }
    visited[y * input.len + x] = true;
    const elevation = input[y][x];

    if (elevation == '9') {
        return 1;
    }
    var trails: u64 = 0;
    if (x + 1 < input.len and input[y][x + 1] == elevation + 1) {
        trails += calcEnds(input, visited, x + 1, y);
    }
    if (x > 0 and input[y][x - 1] == elevation + 1) {
        trails += calcEnds(input, visited, x - 1, y);
    }
    if (y + 1 < input.len and input[y + 1][x] == elevation + 1) {
        trails += calcEnds(input, visited, x, y + 1);
    }
    if (y > 0 and input[y - 1][x] == elevation + 1) {
        trails += calcEnds(input, visited, x, y - 1);
    }
    return trails;
}

fn calcTrails(input: [][]const u8, x: usize, y: usize) u64 {
    const elevation = input[y][x];

    if (elevation == '9') {
        return 1;
    }
    var trails: u64 = 0;
    if (x + 1 < input.len and input[y][x + 1] == elevation + 1) {
        trails += calcTrails(input, x + 1, y);
    }
    if (x > 0 and input[y][x - 1] == elevation + 1) {
        trails += calcTrails(input, x - 1, y);
    }
    if (y + 1 < input.len and input[y + 1][x] == elevation + 1) {
        trails += calcTrails(input, x, y + 1);
    }
    if (y > 0 and input[y - 1][x] == elevation + 1) {
        trails += calcTrails(input, x, y - 1);
    }
    return trails;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc10/input.txt", allocator);
    var ends: u64 = 0;
    var trails: u64 = 0;
    for (input, 0..) |line, y| {
        for (line, 0..) |elevation, x| {
            if (elevation == '0') {
                const visited = try allocator.alloc(bool, input.len * input.len);
                ends += calcEnds(input, visited, x, y);
                trails += calcTrails(input, x, y);
            }
        }
    }
    std.debug.print("Day 10 Part 1: {d}\n", .{ends});
    std.debug.print("Day 10 Part 2: {d}\n", .{trails});
}
