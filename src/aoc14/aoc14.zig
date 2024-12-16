const std = @import("std");
const shared = @import("../shared.zig");

const HEIGHT = 103;
const WIDTH = 101;

const Vec2 = struct {
    x: i32,
    y: i32,

    fn parse(slice: []const u8, allocator: std.mem.Allocator) !Vec2 {
        const parts = try shared.splitCharSlice(slice, ",");
        const vec = try allocator.create(Vec2);
        vec.* = .{
            .x = try std.fmt.parseInt(i32, parts[0], 10),
            .y = try std.fmt.parseInt(i32, parts[1], 10),
        };
        return vec.*;
    }
};

const Robot = struct {
    pos: Vec2,
    vel: Vec2,
};

fn remPositive(a: i32, b: i32) i32 {
    const rem = @rem(a, b);
    return if (rem < 0) rem + b else rem;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc14/input.txt", allocator);
    var robots = std.ArrayList(*Robot).init(allocator);
    for (input) |line| {
        const parts = try shared.splitCharSlice(line, " ");
        const pos = (try shared.splitCharSlice(parts[0], "="))[1];
        const vel = (try shared.splitCharSlice(parts[1], "="))[1];
        const robot = try allocator.create(Robot);
        robot.* = .{
            .pos = try Vec2.parse(pos, allocator),
            .vel = try Vec2.parse(vel, allocator),
        };
        try robots.append(robot);
    }

    for (robots.items) |robot| {
        robot.pos.x = remPositive(robot.pos.x + 100 * robot.vel.x, WIDTH);
        robot.pos.y = remPositive(robot.pos.y + 100 * robot.vel.y, HEIGHT);
    }

    var sums = [4]u32{ 0, 0, 0, 0 };

    for (robots.items) |robot| {
        if (robot.pos.x < @divExact(WIDTH - 1, 2) and robot.pos.y < @divExact(HEIGHT - 1, 2)) {
            sums[0] += 1;
        } else if (robot.pos.x > @divExact(WIDTH - 1, 2) and robot.pos.y < @divExact(HEIGHT - 1, 2)) {
            sums[1] += 1;
        } else if (robot.pos.x < @divExact(WIDTH - 1, 2) and robot.pos.y > @divExact(HEIGHT - 1, 2)) {
            sums[2] += 1;
        } else if (robot.pos.x > @divExact(WIDTH - 1, 2) and robot.pos.y > @divExact(HEIGHT - 1, 2)) {
            sums[3] += 1;
        }
    }

    var count: u32 = 0;
    var isUnique = try allocator.alloc(bool, HEIGHT * WIDTH);
    outer: while (true) {
        count += 1;
        for (robots.items) |robot| {
            robot.pos.x = remPositive(robot.pos.x + robot.vel.x, WIDTH);
            robot.pos.y = remPositive(robot.pos.y + robot.vel.y, HEIGHT);
        }

        for (robots.items) |robot| {
            const index: usize = @intCast(robot.pos.y * @as(i32, @intCast(WIDTH)) + robot.pos.x);
            if (isUnique[index]) {
                for (isUnique, 0..) |_, i| {
                    isUnique[i] = false;
                }
                continue :outer;
            }
            isUnique[index] = true;
        }
        break;
    }

    std.debug.print("Day 14 Part 1: {d}\n", .{sums[0] * sums[1] * sums[2] * sums[3]});
    std.debug.print("Day 14 Part 2: {d}\n", .{count + 1});
}
