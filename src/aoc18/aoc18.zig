const std = @import("std");
const shared = @import("../shared.zig");

const HEIGHT = 71;

const Vec2 = struct {
    x: u32,
    y: u32,
};

fn BufMinHeap(comptime T: type) type {
    return struct {
        data: []Node,
        allocator: *const std.mem.Allocator,
        end: usize = 0,

        const Node = struct {
            value: T,
            priority: u32,
        };

        pub fn init(allocator: std.mem.Allocator) !BufMinHeap(T) {
            const data = try allocator.alloc(Node, 100);
            return BufMinHeap(T){
                .data = data,
                .allocator = &allocator,
                .end = 0,
            };
        }

        fn siftUp(self: *BufMinHeap(T), index: usize) void {
            if (index == 0) return;
            const parent = (index - 1) / 2;
            if (self.data[index].priority < self.data[parent].priority) {
                const temp = self.data[index];
                self.data[index] = self.data[parent];
                self.data[parent] = temp;
                self.siftUp(parent);
            }
        }

        fn siftDown(self: *BufMinHeap(T), index: usize) void {
            const left = 2 * index + 1;
            const right = 2 * index + 2;
            var smallest = index;
            if (left < self.end and self.data[left].priority < self.data[smallest].priority) {
                smallest = left;
            }
            if (right < self.end and self.data[right].priority < self.data[smallest].priority) {
                smallest = right;
            }
            if (smallest != index) {
                const temp = self.data[index];
                self.data[index] = self.data[smallest];
                self.data[smallest] = temp;
                self.siftDown(smallest);
            }
        }

        pub fn insert(self: *BufMinHeap(T), value: T, priority: u32) void {
            self.data[self.end] = Node{ .value = value, .priority = priority };
            self.end += 1;
            self.siftUp(self.end - 1);
        }

        pub fn removeMin(self: *BufMinHeap(T)) T {
            const result = self.data[0].value;
            self.end -= 1;
            self.data[0] = self.data[self.end];
            self.siftDown(0);
            return result;
        }

        pub fn decreasePriority(self: *BufMinHeap(T), value: T, priority: u32) void {
            var index: usize = 0;
            while (index < self.end) {
                if (self.data[index].value == value) {
                    self.data[index].priority = priority;
                    self.siftUp(index);
                    return;
                }
                index += 1;
            }
        }
    };
}

fn toIndex(x: u32, y: u32) u32 {
    return y * HEIGHT + x;
}

fn toX(index: u32) u32 {
    return index % HEIGHT;
}

fn toY(index: u32) u32 {
    return index / HEIGHT;
}

fn findPath(map: [][]u8, allocator: std.mem.Allocator) !u32 {
    var priorityQueue = try BufMinHeap(u32).init(allocator);
    var visited = try allocator.alloc(u32, HEIGHT * HEIGHT);
    for (0..HEIGHT) |i| {
        for (0..HEIGHT) |j| {
            visited[i * HEIGHT + j] = std.math.maxInt(u32);
        }
    }

    priorityQueue.insert(toIndex(0, 0), 0);
    visited[toIndex(0, 0)] = 0;
    while (priorityQueue.end != 0) {
        const current = priorityQueue.removeMin();
        const x = current % HEIGHT;
        const y = current / HEIGHT;

        if (x > 0 and map[y][x - 1] != '#') {
            const oldBest = visited[toIndex(x - 1, y)];
            if (oldBest == std.math.maxInt(u32)) {
                visited[toIndex(x - 1, y)] = visited[current] + 1;
                priorityQueue.insert(toIndex(x - 1, y), visited[current] + 1);
            } else if (visited[current] + 1 < oldBest) {
                visited[toIndex(x - 1, y)] = visited[current] + 1;
                priorityQueue.decreasePriority(toIndex(x - 1, y), visited[current] + 1);
            }
        }
        if (x < HEIGHT - 1 and map[y][x + 1] != '#') {
            const oldBest = visited[toIndex(x + 1, y)];
            if (oldBest == std.math.maxInt(u32)) {
                visited[toIndex(x + 1, y)] = visited[current] + 1;
                priorityQueue.insert(toIndex(x + 1, y), visited[current] + 1);
            } else if (visited[current] + 1 < oldBest) {
                visited[toIndex(x + 1, y)] = visited[current] + 1;
                priorityQueue.decreasePriority(toIndex(x + 1, y), visited[current] + 1);
            }
        }
        if (y > 0 and map[y - 1][x] != '#') {
            const oldBest = visited[toIndex(x, y - 1)];
            if (oldBest == std.math.maxInt(u32)) {
                visited[toIndex(x, y - 1)] = visited[current] + 1;
                priorityQueue.insert(toIndex(x, y - 1), visited[current] + 1);
            } else if (visited[current] + 1 < oldBest) {
                visited[toIndex(x, y - 1)] = visited[current] + 1;
                priorityQueue.decreasePriority(toIndex(x, y - 1), visited[current] + 1);
            }
        }
        if (y < HEIGHT - 1 and map[y + 1][x] != '#') {
            const oldBest = visited[toIndex(x, y + 1)];
            if (oldBest == std.math.maxInt(u32)) {
                visited[toIndex(x, y + 1)] = visited[current] + 1;
                priorityQueue.insert(toIndex(x, y + 1), visited[current] + 1);
            } else if (visited[current] + 1 < oldBest) {
                visited[toIndex(x, y + 1)] = visited[current] + 1;
                priorityQueue.decreasePriority(toIndex(x, y + 1), visited[current] + 1);
            }
        }
    }
    return visited[toIndex(HEIGHT - 1, HEIGHT - 1)];
}

fn modMap(map: [][]u8, coords: []Vec2, start: u32, needle: u32, end: u32) void {
    for (start..needle) |i| {
        map[coords[i].x][coords[i].y] = '#';
    }
    for (needle..end) |i| {
        map[coords[i].x][coords[i].y] = '.';
    }
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc18/input.txt", allocator);
    const map = try allocator.alloc([]u8, HEIGHT);
    const coords = try allocator.alloc(Vec2, input.len);
    for (0..HEIGHT) |i| {
        map[i] = try allocator.alloc(u8, HEIGHT);
    }
    for (input, 0..) |line, i| {
        const nums = try shared.splitCharSlice(line, ",");
        const num1 = try std.fmt.parseInt(u8, nums[0], 10);
        const num2 = try std.fmt.parseInt(u8, nums[1], 10);
        coords[i] = Vec2{ .x = num1, .y = num2 };
    }
    modMap(map, coords, 0, 1024, @intCast(input.len));
    const length = try findPath(map, allocator);
    std.debug.print("Day 18 Part 1: {}\n", .{length});

    var start: u32 = 1024;
    var end: u32 = @intCast(input.len);
    while (end > start + 1) {
        const needle: u32 = @divTrunc(end + start, 2);
        modMap(map, coords, start, needle, end);
        const len = try findPath(map, allocator);
        if (len == std.math.maxInt(u32)) {
            end = needle;
        } else {
            start = needle;
        }
    }
    std.debug.print("Day 18 Part 2: {d},{d}\n", .{ coords[start].x, coords[start].y });
}
