const std = @import("std");
const shared = @import("../shared.zig");

const Vec2 = struct {
    x: i32,
    y: i32,
};

fn visitedIndex(pos: Vec2, dir: Vec2, len: usize) usize {
    const dirIndex: i32 = if (dir.x == 1) 0 else if (dir.x == -1) 1 else if (dir.y == 1) 2 else 3;
    return @intCast((pos.y * @as(i32, @intCast(len)) + pos.x) * 4 + dirIndex);
}

fn visitedIndexToDir(index: usize) Vec2 {
    const dirIndex: usize = @rem(index, 4);
    switch (dirIndex) {
        0 => return Vec2{ .x = 1, .y = 0 },
        1 => return Vec2{ .x = -1, .y = 0 },
        2 => return Vec2{ .x = 0, .y = 1 },
        3 => return Vec2{ .x = 0, .y = -1 },
        else => return Vec2{ .x = 0, .y = 0 },
    }
}

fn visitedIndexToPos(index: usize, len: usize) Vec2 {
    const posIndex: usize = @divTrunc(index, 4);
    return Vec2{ .x = @intCast(@rem(posIndex, len)), .y = @intCast(@divTrunc(posIndex, len)) };
}

fn findPath(map: [][]const u8, visited: []usize, stillToVisit: *std.ArrayList(usize)) !void {
    while (stillToVisit.*.items.len != 0) {
        std.mem.sort(usize, stillToVisit.*.items, &visited, compare);
        const minIndex = stillToVisit.swapRemove(stillToVisit.*.items.len - 1);
        const minValue = visited[minIndex];
        if (minValue == std.math.maxInt(usize)) {
            break;
        }
        const pos = visitedIndexToPos(minIndex, map.len);
        const dir = visitedIndexToDir(minIndex);
        const strait = visitedIndex(Vec2{ .x = pos.x + dir.x, .y = pos.y + dir.y }, dir, map.len);
        if (map[@intCast(pos.y + dir.y)][@intCast(pos.x + dir.x)] != '#') {
            if (visited[strait] == std.math.maxInt(usize)) {
                visited[strait] = minValue + 1;
                try stillToVisit.append(strait);
            } else {
                visited[strait] = @min(visited[strait], minValue + 1);
            }
        }
        const left = visitedIndex(pos, Vec2{ .x = dir.y, .y = dir.x }, map.len);
        if (visited[left] == std.math.maxInt(usize)) {
            visited[left] = minValue + 1000;
            try stillToVisit.append(left);
        } else {
            visited[left] = @min(visited[left], minValue + 1000);
        }
        const right = visitedIndex(pos, Vec2{ .x = -dir.y, .y = -dir.x }, map.len);
        if (visited[right] == std.math.maxInt(usize)) {
            visited[right] = minValue + 1000;
            try stillToVisit.append(right);
        } else {
            visited[right] = @min(visited[right], minValue + 1000);
        }
    }
}

fn compare(context: *const []usize, a: usize, b: usize) bool {
    return context.*[a] > context.*[b];
}

fn findPaths(counted: []bool, visited: []usize, pos: Vec2, dir: Vec2, current: usize, len: usize) void {
    const visitedIdx = visitedIndex(pos, dir, len);
    if (counted[visitedIdx]) {
        return;
    }
    counted[visitedIdx] = true;
    const strait = visitedIndex(Vec2{ .x = pos.x - dir.x, .y = pos.y - dir.y }, dir, len);
    if (visited[strait] != std.math.maxInt(usize) and visited[strait] + 1 == current) {
        findPaths(counted, visited, Vec2{ .x = pos.x - dir.x, .y = pos.y - dir.y }, dir, visited[strait], len);
    }
    const left = visitedIndex(pos, Vec2{ .x = dir.y, .y = dir.x }, len);
    if (visited[left] != std.math.maxInt(usize) and visited[left] + 1000 == current) {
        findPaths(counted, visited, pos, Vec2{ .x = dir.y, .y = dir.x }, visited[left], len);
    }
    const right = visitedIndex(pos, Vec2{ .x = -dir.y, .y = -dir.x }, len);
    if (visited[right] != std.math.maxInt(usize) and visited[right] + 1000 == current) {
        findPaths(counted, visited, pos, Vec2{ .x = -dir.y, .y = -dir.x }, visited[right], len);
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc16/input.txt", allocator);
    const visited = try allocator.alloc(usize, input.len * input[0].len * 4);
    var stillToVisit = std.ArrayList(usize).init(allocator);

    for (0..visited.len) |i| {
        visited[i] = std.math.maxInt(usize);
    }

    const start = visitedIndex(Vec2{ .x = 1, .y = @intCast(input.len - 2) }, Vec2{ .x = 1, .y = 0 }, input.len);
    visited[start] = 0;
    try stillToVisit.append(start);

    try findPath(input, visited, &stillToVisit);

    const victoryPos = Vec2{ .y = 1, .x = @intCast(input.len - 2) };
    var victoryDir = Vec2{ .x = 1, .y = 0 };
    var victoryValue: usize = std.math.maxInt(usize);
    const dirs = [4]Vec2{
        Vec2{ .x = 1, .y = 0 },
        Vec2{ .x = -1, .y = 0 },
        Vec2{ .x = 0, .y = 1 },
        Vec2{ .x = 0, .y = -1 },
    };
    for (dirs) |dir| {
        const index = visitedIndex(victoryPos, dir, input.len);
        if (victoryValue > visited[index]) {
            victoryValue = visited[index];
            victoryDir = dir;
        }
    }

    const counted = try allocator.alloc(bool, input.len * input[0].len * 4);
    findPaths(counted, visited, victoryPos, victoryDir, victoryValue, input.len);

    var count: usize = 0;
    for (0..input.len * input.len) |i| {
        if (counted[4 * i] or counted[4 * i + 1] or counted[4 * i + 2] or counted[4 * i + 3]) {
            count += 1;
        }
    }

    std.debug.print("Day 16 Part 1: {}\n", .{victoryValue});
    std.debug.print("Day 16 Part 2: {}\n", .{count});
}
