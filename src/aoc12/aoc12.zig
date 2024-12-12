const std = @import("std");
const shared = @import("../shared.zig");

const Type = enum {
    Top,
    Bottom,
    Right,
    Left,
};

const Perimeter = struct {
    x: usize,
    y: usize,
    type: Type,
    pub fn lessThanY(_: @TypeOf(.{}), self: *Perimeter, other: *Perimeter) bool {
        // sorting function that firstly separates types then sorts by y and lastly by x
        if (self.type != other.type) {
            return @intFromEnum(self.type) < @intFromEnum(other.type);
        }
        if (self.y != other.y) {
            return self.y < other.y;
        }
        return self.x < other.x;
    }

    pub fn lessThanX(_: @TypeOf(.{}), self: *Perimeter, other: *Perimeter) bool {
        // sorting function that firstly separates types then sorts by x and lastly by y
        if (self.type != other.type) {
            return @intFromEnum(self.type) > @intFromEnum(other.type);
        }
        if (self.x != other.x) {
            return self.x < other.x;
        }
        return self.y < other.y;
    }
};

const Field = struct {
    area: u32,
    perimeter: u32,
    perimeters: std.ArrayList(*Perimeter),

    pub fn calculatePerimeters(self: *Field) u32 {
        var count: u32 = 0;

        std.mem.sort(*Perimeter, self.perimeters.items, .{}, Perimeter.lessThanY);
        for (self.perimeters.items, 0..) |perimeter, i| {
            if (i == 0) {
                continue;
            }
            if (perimeter.type == Type.Right) {
                count += 1;
                break;
            }
            if (perimeter.type != self.perimeters.items[i - 1].type or perimeter.y != self.perimeters.items[i - 1].y or perimeter.x != self.perimeters.items[i - 1].x + 1) {
                count += 1;
            }
        }

        std.mem.sort(*Perimeter, self.perimeters.items, .{}, Perimeter.lessThanX);
        for (self.perimeters.items, 0..) |perimeter, i| {
            if (i == 0) {
                continue;
            }
            if (perimeter.type == Type.Bottom) {
                count += 1;
                break;
            }
            if (perimeter.type != self.perimeters.items[i - 1].type or perimeter.x != self.perimeters.items[i - 1].x or perimeter.y != self.perimeters.items[i - 1].y + 1) {
                count += 1;
            }
        }

        return count;
    }
};

fn calculate(field: *Field, x: usize, y: usize, input: []const []const u8, calculated: []bool, allocator: std.mem.Allocator) !void {
    if (calculated[y * input.len + x]) {
        return;
    }
    field.area += 1;

    calculated[y * input.len + x] = true;

    if (x > 0 and input[y][x - 1] == input[y][x]) {
        try calculate(field, x - 1, y, input, calculated, allocator);
    } else {
        field.perimeter += 1;
        const perimeter = try allocator.create(Perimeter);
        perimeter.* = Perimeter{ .x = x, .y = y, .type = Type.Left };
        try field.perimeters.append(perimeter);
    }

    if (x < input.len - 1 and input[y][x + 1] == input[y][x]) {
        try calculate(field, x + 1, y, input, calculated, allocator);
    } else {
        field.perimeter += 1;
        const perimeter = try allocator.create(Perimeter);
        perimeter.* = Perimeter{ .x = x, .y = y, .type = Type.Right };
        try field.perimeters.append(perimeter);
    }

    if (y > 0 and input[y - 1][x] == input[y][x]) {
        try calculate(field, x, y - 1, input, calculated, allocator);
    } else {
        field.perimeter += 1;
        const perimeter = try allocator.create(Perimeter);
        perimeter.* = Perimeter{ .x = x, .y = y, .type = Type.Top };
        try field.perimeters.append(perimeter);
    }

    if (y < input.len - 1 and input[y + 1][x] == input[y][x]) {
        try calculate(field, x, y + 1, input, calculated, allocator);
    } else {
        field.perimeter += 1;
        const perimeter = try allocator.create(Perimeter);
        perimeter.* = Perimeter{ .x = x, .y = y, .type = Type.Bottom };
        try field.perimeters.append(perimeter);
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc12/input.txt", allocator);
    const calculated = try allocator.alloc(bool, input.len * input.len);
    var sum: u32 = 0;
    var sumCalculated: u32 = 0;
    for (input, 0..) |line, y| {
        for (line, 0..) |_, x| {
            if (calculated[y * input.len + x]) {
                continue;
            }
            const field = try allocator.create(Field);
            field.* = Field{ .area = 0, .perimeter = 0, .perimeters = std.ArrayList(*Perimeter).init(allocator) };
            try calculate(field, x, y, input, calculated, allocator);
            const perim = field.calculatePerimeters();
            sum += field.area * field.perimeter;
            sumCalculated += field.area * perim;
        }
    }

    std.debug.print("Day 12 Part 1: {}\n", .{sum});
    std.debug.print("Day 12 Part 2: {}\n", .{sumCalculated});
}
