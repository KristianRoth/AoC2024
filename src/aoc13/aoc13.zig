const std = @import("std");
const shared = @import("../shared.zig");

fn calc_gcd(a: i64, b: i64) i64 {
    return @as(i64, @intCast(std.math.gcd(@as(u64, @intCast(a)), @as(u64, @intCast(b)))));
}

fn findSolution(ax: i64, ay: i64, bx: i64, by: i64, tx: i64, ty: i64) i64 {
    const gcd = calc_gcd(ax, ay);

    const dx = @divExact(ay, @as(i64, @intCast(gcd)));
    const dy = @divExact(ax, @as(i64, @intCast(gcd)));

    const bb = std.math.divExact(i64, tx * dx - ty * dy, bx * dx - by * dy) catch return 0;
    const aa = std.math.divExact(i64, tx - bx * bb, ax) catch return 0;
    return 3 * aa + bb;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc13/input.txt", allocator);
    var i: usize = 0;
    var sum: i64 = 0;
    var sumBig: i64 = 0;
    while (i < input.len) {
        const ax = try std.fmt.parseInt(i64, input[i][12..14], 10);
        const ay = try std.fmt.parseInt(i64, input[i][18..20], 10);
        const bx = try std.fmt.parseInt(i64, input[i + 1][12..14], 10);
        const by = try std.fmt.parseInt(i64, input[i + 1][18..20], 10);
        const ans = try shared.splitCharSlice(input[i + 2], ", ");
        const tx = try std.fmt.parseInt(i64, ans[0][9..], 10);
        const ty = try std.fmt.parseInt(i64, ans[1][2..], 10);
        sum += findSolution(ax, ay, bx, by, tx, ty);
        sumBig += findSolution(ax, ay, bx, by, tx + 10000000000000, ty + 10000000000000);
        i += 4;
    }

    std.debug.print("Day 13 Part 1: {d}\n", .{sum});
    std.debug.print("Day 13 Part 2: {d}\n", .{sumBig});
}
