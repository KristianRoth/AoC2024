const std = @import("std");
const shared = @import("../shared.zig");

const Vec2 = struct { x: i32, y: i32 };

fn visitedIndex(location: Vec2, dir: Vec2, width: usize) usize {
    const x: usize = @intCast(location.x);
    const y: usize = @intCast(location.y);
    const dirIndex: usize = if (dir.x == 0 and dir.y == -1)
        0
    else if (dir.x == 1 and dir.y == 0)
        1
    else if (dir.x == 0 and dir.y == 1)
        2
    else
        3;

    return @intCast(x + y * width + dirIndex * width * width);
}

fn isLooping(start_location: Vec2, start_dir: Vec2, chars: *[][]u8, old_visited: *[]const bool, allocator: std.mem.Allocator) !bool {
    var visited = try allocator.alloc(bool, old_visited.len);
    defer allocator.free(visited);
    std.mem.copyForwards(bool, visited, old_visited.*);
    var location = start_location;
    var dir = start_dir;
    while (0 <= location.x + dir.x and location.x + dir.x < chars.len and 0 <= location.y + dir.y and location.y + dir.y < chars.len) {
        if (visited[visitedIndex(location, dir, chars.len)]) {
            return true;
        }
        if (chars.*[@intCast(location.y + dir.y)][@intCast(location.x + dir.x)] == '#') {
            visited[visitedIndex(location, dir, chars.len)] = true;
            const temp = Vec2{ .x = -dir.y, .y = dir.x };
            dir = temp;
            continue;
        }
        visited[visitedIndex(location, dir, chars.len)] = true;
        location.x += dir.x;
        location.y += dir.y;
    }
    return false;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc6/input.txt", allocator);
    var mutable_chars = try allocator.alloc([]u8, input.len);
    var visited = try allocator.alloc(bool, input.len * input[0].len * 4);
    defer allocator.free(input);
    defer allocator.free(mutable_chars);
    defer allocator.free(visited);
    for (input, 0..) |line, i| {
        mutable_chars[i] = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, mutable_chars[i], line);
    }

    var location: Vec2 = .{ .x = 0, .y = 0 };
    for (mutable_chars, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == '^') {
                location.x = @intCast(j);
                location.y = @intCast(i);
            }
        }
    }
    var count: u32 = 1;
    var loop_count: u32 = 0;
    var dir: Vec2 = .{ .x = 0, .y = -1 };
    mutable_chars[@intCast(location.y)][@intCast(location.x)] = 'X';

    while (0 <= location.x + dir.x and location.x + dir.x < mutable_chars[0].len and 0 <= location.y + dir.y and location.y + dir.y < mutable_chars.len) {
        if (mutable_chars[@intCast(location.y + dir.y)][@intCast(location.x + dir.x)] == '#') {
            visited[visitedIndex(location, dir, mutable_chars.len)] = true;
            const temp = Vec2{ .x = -dir.y, .y = dir.x };
            dir = temp;
            continue;
        } else if (mutable_chars[@intCast(location.y + dir.y)][@intCast(location.x + dir.x)] == '.') {
            mutable_chars[@intCast(location.y + dir.y)][@intCast(location.x + dir.x)] = '#';
            if (try isLooping(location, dir, &mutable_chars, &visited, allocator)) {
                loop_count += 1;
            } else {
                mutable_chars[@intCast(location.y + dir.y)][@intCast(location.x + dir.x)] = '.';
            }
        }
        visited[visitedIndex(location, dir, mutable_chars.len)] = true;
        location.x += dir.x;
        location.y += dir.y;
        if (mutable_chars[@intCast(location.y)][@intCast(location.x)] != 'X') {
            count += 1;
        }
        mutable_chars[@intCast(location.y)][@intCast(location.x)] = 'X';
    }
    std.debug.print("Day 6 Part 1: {}\n", .{count});
    std.debug.print("Day 6 Part 2: {}\n", .{loop_count});
}
