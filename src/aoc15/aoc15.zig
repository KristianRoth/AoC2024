const std = @import("std");
const shared = @import("../shared.zig");

const Vec2 = struct {
    x: i32,
    y: i32,
};

fn move(map: *[][]u8, dir: u8, pos: *Vec2) void {
    const x: i32 = if (dir == '<') -1 else if (dir == '>') 1 else 0;
    const y: i32 = if (dir == '^') -1 else if (dir == 'v') 1 else 0;
    for (1..map.len) |j| {
        const i: i32 = @intCast(j);
        if (map.*[@intCast(pos.y + y * i)][@intCast(pos.x + x * i)] == 'O') {
            continue;
        }
        if (map.*[@intCast(pos.y + y * i)][@intCast(pos.x + x * i)] == '#') {
            return;
        }
        if (map.*[@intCast(pos.y + y * i)][@intCast(pos.x + x * i)] == '.') {
            map.*[@intCast(pos.y + y * i)][@intCast(pos.x + x * i)] = map.*[@intCast(pos.y + y)][@intCast(pos.x + x)];
            map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] = '@';
            map.*[@intCast(pos.y)][@intCast(pos.x)] = '.';
            pos.x += x;
            pos.y += y;
            return;
        }
    }
}

fn goodToMove(map: *[][]u8, dir: u8, pos: *Vec2) bool {
    const x: i32 = if (dir == '<') -1 else if (dir == '>') 1 else 0;
    const y: i32 = if (dir == '^') -1 else if (dir == 'v') 1 else 0;
    if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '#') {
        return false;
    }
    if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '.') {
        return true;
    }
    if ((map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[' or map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == ']') and y != 0) {
        const offset: i32 = if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[') 1 else -1;
        var newPos1 = Vec2{ .x = pos.x, .y = pos.y + y };
        var newPos2 = Vec2{ .x = pos.x + offset, .y = pos.y + y };
        return goodToMove(map, dir, &newPos1) and goodToMove(map, dir, &newPos2);
    }
    if ((map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[' or map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == ']') and x != 0) {
        var newPos1 = Vec2{ .x = pos.x + 2 * x, .y = pos.y };
        return goodToMove(map, dir, &newPos1);
    }

    return false;
}

fn doMove(map: *[][]u8, dir: u8, pos: *Vec2) void {
    const x: i32 = if (dir == '<') -1 else if (dir == '>') 1 else 0;
    const y: i32 = if (dir == '^') -1 else if (dir == 'v') 1 else 0;
    if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '#') {
        return;
    }
    if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '.') {
        map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] = map.*[@intCast(pos.y)][@intCast(pos.x)];
        map.*[@intCast(pos.y)][@intCast(pos.x)] = '.';
        return;
    }
    if ((map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[' or map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == ']') and y != 0) {
        const offset: i32 = if (map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[') 1 else -1;

        var newPos1 = Vec2{ .x = pos.x, .y = pos.y + y };
        var newPos2 = Vec2{ .x = pos.x + offset, .y = pos.y + y };
        doMove(map, dir, &newPos1);
        doMove(map, dir, &newPos2);

        map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] = map.*[@intCast(pos.y)][@intCast(pos.x)];
        map.*[@intCast(pos.y)][@intCast(pos.x)] = '.';
    }
    if ((map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == '[' or map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] == ']') and x != 0) {
        var newPos1 = Vec2{ .x = pos.x + 2 * x, .y = pos.y };
        var newPos2 = Vec2{ .x = pos.x + x, .y = pos.y };

        doMove(map, dir, &newPos1);
        doMove(map, dir, &newPos2);

        map.*[@intCast(pos.y + y)][@intCast(pos.x + x)] = map.*[@intCast(pos.y)][@intCast(pos.x)];
        map.*[@intCast(pos.y)][@intCast(pos.x)] = '.';
    }
}

fn wideMove(map: *[][]u8, dir: u8, pos: *Vec2) void {
    if (goodToMove(map, dir, pos)) {
        doMove(map, dir, pos);
        pos.x += if (dir == '<') -1 else if (dir == '>') 1 else 0;
        pos.y += if (dir == '^') -1 else if (dir == 'v') 1 else 0;
    }
}

fn printMap(map: *[][]u8) void {
    for (0..map.len) |i| {
        for (0..map.*[0].len) |j| {
            std.debug.print("{c}", .{map.*[i][j]});
        }
        std.debug.print("\n", .{});
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc15/input.txt", allocator);
    var map = try allocator.alloc([]u8, input[0].len);
    var wideMap = try allocator.alloc([]u8, input[0].len);
    var pos = Vec2{ .x = 0, .y = 0 };
    var widePos = Vec2{ .x = 0, .y = 0 };
    for (0..input[0].len) |i| {
        map[i] = try allocator.alloc(u8, input[0].len);
        wideMap[i] = try allocator.alloc(u8, input[0].len * 2);
        for (0..input[0].len) |j| {
            map[i][j] = input[i][j];
            if (map[i][j] == '@') {
                pos.x = @intCast(j);
                pos.y = @intCast(i);
                widePos.x = @intCast(2 * j);
                widePos.y = @intCast(i);
            }
            if (input[i][j] == 'O') {
                wideMap[i][2 * j] = '[';
                wideMap[i][2 * j + 1] = ']';
            } else if (input[i][j] == '.') {
                wideMap[i][2 * j] = '.';
                wideMap[i][2 * j + 1] = '.';
            } else if (input[i][j] == '@') {
                wideMap[i][2 * j] = '@';
                wideMap[i][2 * j + 1] = '.';
            } else if (input[i][j] == '#') {
                wideMap[i][2 * j] = '#';
                wideMap[i][2 * j + 1] = '#';
            }
        }
    }

    for (input[input[0].len + 1 ..]) |line| {
        for (line) |c| {
            move(&map, c, &pos);
            wideMove(&wideMap, c, &widePos);
        }
    }

    var sum: u64 = 0;
    for (0..map.len) |i| {
        for (0..map.len) |j| {
            if (map[i][j] == 'O') {
                sum += i * 100 + j;
            }
        }
    }

    var wideSum: u64 = 0;
    for (0..wideMap.len) |i| {
        for (0..wideMap[0].len) |j| {
            if (wideMap[i][j] == '[') {
                wideSum += i * 100 + j;
            }
        }
    }

    std.debug.print("Day 15 Part 1: {d}\n", .{sum});
    std.debug.print("Day 15 Part 2: {d}\n", .{wideSum});
}
