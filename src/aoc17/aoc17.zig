const std = @import("std");
const shared = @import("../shared.zig");

fn run(ai: u64, bi: u64, ci: u64, program: []u8, allocator: std.mem.Allocator) ![]u8 {
    var out = std.ArrayList(u8).init(allocator);
    var programCounter: u64 = 0;
    var outCounter: u64 = 0;
    var a = ai;
    var b = bi;
    var c = ci;

    while (programCounter < program.len) {
        const opCode = program[programCounter];
        const operand = program[programCounter + 1];
        const comboOperand: u64 = switch (operand) {
            0...3 => operand,
            4 => a,
            5 => b,
            6 => c,
            else => 0,
        };

        switch (opCode) {
            0 => {
                const result = @divTrunc(a, std.math.pow(u64, 2, comboOperand));
                a = result;
                programCounter += 2;
            },
            1 => {
                const result = b ^ operand;
                b = result;
                programCounter += 2;
            },
            2 => {
                const result = @rem(comboOperand, 8);
                b = result;
                programCounter += 2;
            },
            3 => {
                if (a != 0) {
                    programCounter = operand;
                } else {
                    programCounter += 2;
                }
            },
            4 => {
                const result = b ^ c;
                b = result;
                programCounter += 2;
            },
            5 => {
                const result: u8 = @intCast(@rem(comboOperand, 8));
                try out.append(result);
                outCounter += 1;
                programCounter += 2;
            },
            6 => {
                const result = @divTrunc(a, std.math.pow(u64, 2, comboOperand));
                b = result;
                programCounter += 2;
            },
            7 => {
                const result = @divTrunc(a, std.math.pow(u64, 2, comboOperand));
                c = result;
                programCounter += 2;
            },
            else => unreachable,
        }
    }
    return out.toOwnedSlice();
}

fn findA(program: []u8, allocator: std.mem.Allocator, start: u64, progIdx: usize) !u64 {
    for (0..8) |i| {
        const newASelf = (start << 3) | i;
        const newOut = try run(newASelf, 0, 0, program, allocator);
        if (newOut[0] == program[program.len - progIdx - 1]) {
            if (progIdx == program.len - 1) {
                return newASelf;
            }
            const rest = try findA(program, allocator, newASelf, progIdx + 1);
            if (rest == newASelf) {
                continue;
            }
            return rest;
        }
    }
    return start;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc17/input.txt", allocator);
    const a = try std.fmt.parseInt(u64, input[0][12..], 10);
    const b = try std.fmt.parseInt(u64, input[1][12..], 10);
    const c = try std.fmt.parseInt(u64, input[2][12..], 10);
    const programLen = @divExact(input[4][9..].len + 1, 2);
    const program = try allocator.alloc(u8, programLen);
    for (0..programLen) |i| {
        program[i] = try std.fmt.parseInt(u8, input[4][9 + i * 2 .. 10 + i * 2], 10);
    }

    const out = try run(a, b, c, program, allocator);

    std.debug.print("Day 17 Part 1: ", .{});
    for (out[0 .. out.len - 1]) |o| {
        std.debug.print("{d},", .{o});
    }
    std.debug.print("{d}\n", .{out[out.len - 1]});

    const aSelf = try findA(program, allocator, 0, 0);
    std.debug.print("Day 17 Part 2: {d}\n", .{aSelf});
}
