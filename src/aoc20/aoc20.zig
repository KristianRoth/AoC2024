const std = @import("std");
const shared = @import("../shared.zig");

const Vec2 = struct {
    x: usize,
    y: usize,
};

fn traverse(
    input: [][]const u8,
    start: Vec2,
    comptime T: type,
    context: *T,
    callback: fn (*T, Vec2) void,
) void {
    var last = start;
    var current = start;

    while (true) {
        callback(context, current);
        if (input[current.y][current.x] == 'E') {
            break;
        }
        if (input[current.y][current.x + 1] != '#' and current.x + 1 != last.x) {
            last = current;
            current = Vec2{ .x = current.x + 1, .y = current.y };
        } else if (input[current.y][current.x - 1] != '#' and current.x - 1 != last.x) {
            last = current;
            current = Vec2{ .x = current.x - 1, .y = current.y };
        } else if (input[current.y + 1][current.x] != '#' and current.y + 1 != last.y) {
            last = current;
            current = Vec2{ .x = current.x, .y = current.y + 1 };
        } else if (input[current.y - 1][current.x] != '#' and current.y - 1 != last.y) {
            last = current;
            current = Vec2{ .x = current.x, .y = current.y - 1 };
        } else {
            unreachable;
        }
    }
}

const LenCtx = struct {
    len: usize,
    times: *[][]usize,
};

fn populateTimes(
    context: *LenCtx,
    pos: Vec2,
) void {
    context.times.*[pos.y][pos.x] = context.len;
    context.len += 1;
}

const ShortCutCtx = struct {
    count: usize,
    times: *[][]usize,
};

fn countShortCuts(
    context: *ShortCutCtx,
    pos: Vec2,
) void {
    const currentTime = context.times.*[pos.y][pos.x];
    const minimum = currentTime + 2 + 100;
    if (pos.x > 1 and context.times.*[pos.y][pos.x - 2] >= minimum) {
        context.count += 1;
    }
    if (pos.x < context.times.*[0].len - 2 and context.times.*[pos.y][pos.x + 2] >= minimum) {
        context.count += 1;
    }
    if (pos.y > 1 and context.times.*[pos.y - 2][pos.x] >= minimum) {
        context.count += 1;
    }
    if (pos.y < context.times.len - 2 and context.times.*[pos.y + 2][pos.x] >= minimum) {
        context.count += 1;
    }
}

fn countUberShortCuts(
    context: *ShortCutCtx,
    pos: Vec2,
) void {
    const maximum = 21;
    for (0..21) |x| {
        for (0..maximum - x) |y| {
            const currentTime = context.times.*[pos.y][pos.x];
            const minimum = currentTime + x + y + 100;
            if (pos.x + x < context.times.*[0].len and
                pos.y + y < context.times.len and
                context.times.*[pos.y + y][pos.x + x] >= minimum)
            {
                context.count += 1;
            }
            if (pos.x + x < context.times.*[0].len and
                pos.y >= y and
                context.times.*[pos.y - y][pos.x + x] >= minimum and
                x != 0 and y != 0)
            {
                context.count += 1;
            }
            if (pos.x >= x and
                pos.y + y < context.times.len and
                context.times.*[pos.y + y][pos.x - x] >= minimum and
                x != 0 and y != 0)
            {
                context.count += 1;
            }
            if (pos.x >= x and
                pos.y >= y and
                context.times.*[pos.y - y][pos.x - x] >= minimum)
            {
                context.count += 1;
            }
        }
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc20/input.txt", allocator);
    var times = try allocator.alloc([]usize, input.len);
    for (input, 0..) |line, i| {
        times[i] = try allocator.alloc(usize, line.len);
        for (0..times.len) |j| {
            times[i][j] = 0;
        }
    }

    var start = Vec2{ .x = 0, .y = 0 };
    for (input, 0..) |line, j| {
        for (line, 0..) |char, i| {
            if (char == 'S') {
                start = Vec2{ .x = i, .y = j };
            }
        }
    }

    var ctx = LenCtx{ .len = 0, .times = &times };
    traverse(input, start, LenCtx, &ctx, populateTimes);
    var shortCutCtx = ShortCutCtx{ .count = 0, .times = &times };
    traverse(input, start, ShortCutCtx, &shortCutCtx, countShortCuts);
    var uberShortCutCtx = ShortCutCtx{ .count = 0, .times = &times };
    traverse(input, start, ShortCutCtx, &uberShortCutCtx, countUberShortCuts);

    std.debug.print("Day 20 Part 1: {}\n", .{shortCutCtx.count});
    std.debug.print("Day 20 Part 2: {}\n", .{uberShortCutCtx.count});
}
