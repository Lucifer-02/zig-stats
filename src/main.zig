const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const assert = std.debug.assert;

pub fn main() !void {}

fn sum(comptime T: type, array: []const T) T {
    var result: T = 0;
    for (array) |i| {
        result += i;
    }
    return result;
}
fn distinct(comptime T: type, array: []T, allocator: Allocator) !void {
    var list = std.ArrayList(i64).init(allocator);
    defer list.deinit();

    const sorted = sort(T, array);

    var current = array[0];
    try list.append(current);
    for (sorted) |value| {
        if (value != current) {
            current = value;
            try list.append(current);
        }
    }

    std.debug.print("Distinct: {any}\n", .{list.items});
}
pub fn mode(comptime T: type, array: []T) T {
    const sorted = sort(T, array);
    var counter: i32 = 0;
    var current = array[0];
    var the_mode: T = undefined;
    var max: i32 = 0;
    for (sorted) |value| {
        if (current != value) {
            if (counter > max) {
                the_mode = current;
                max = counter;
            }
            current = value;
            counter = 1;
        } else {
            counter += 1;
        }
    }
    return the_mode;
}

pub fn mean(comptime T: type, array: []const T) T {
    return switch (T) {
        f32 => meanFloat(f32, array),
        f64 => meanFloat(f64, array),
        else => @compileError("Mean not implemented for " ++ @typeName(T)),
    };
}

pub fn median(comptime T: type, array: []T) T {
    return switch (T) {
        f32 => medianFloat(f32, array),
        f64 => medianFloat(f64, array),
        else => @compileError("Median not implemented for " ++ @typeName(T)),
    };
}

pub fn range(comptime T: type, array: []T) T {
    return std.mem.max(T, array) - std.mem.min(T, array);
}

fn medianFloat(comptime T: type, array: []T) T {
    const length = array.len;
    const sorted = sort(T, array);
    return if (length % 2 == 1) sorted[length / 2] else (sorted[length / 2] + sorted[length / 2 - 1]) / 2;
}

fn meanFloat(comptime T: type, array: []const T) T {
    return sum(T, array) / @intToFloat(T, array.len);
}

fn sort(comptime T: type, array: []T) []T {
    const length = array.len;
    var i: usize = 0;
    while (i < length - 1) : (i += 1) {
        var min_idx = i;
        var j = i + 1;
        while (j < length) : (j += 1) {
            if (array[j] < array[min_idx]) {
                min_idx = j;
            }
        }
        if (min_idx != i) {
            swap(T, array, i, min_idx);
        }
    }

    return array;
}

fn swap(comptime T: type, array: []T, i: usize, j: usize) void {
    const temp = array[i];
    array[i] = array[j];
    array[j] = temp;
}

fn notReturn(comptime T: type, allocator: Allocator) !void{
    var list = std.ArrayList(T).init(allocator);
    defer list.deinit();

    try list.append(1);
    try list.append(2);

    std.debug.print("List: {any}\n", .{list.items});
}

fn isReturn(comptime T: type, allocator: Allocator) !std.ArrayList(T){
    var list = std.ArrayList(T).init(allocator);
    defer list.deinit();

    try list.append(1);
    try list.append(2);

    std.debug.print("List: {any}\n", .{list.items});

    return list;
}

test "sum test" {
    const array1 = [_]f32{ 1, 5, 2, 3, 0.2 };
    const array2 = [_]u32{ 1, 5, 2, 3 };
    try std.testing.expect(sum(f32, &array1) == 11.2);
    try std.testing.expect(sum(u32, &array2) == 11);
}

test "mean test" {
    const array2 = [_]f32{ 1.1, 5.1 };
    const array3 = [_]f64{ 1, 5, 3 };

    std.debug.print("Mean: {d:.2}\n", .{mean(f32, &array2)});
    std.debug.print("Mean: {d:.2}\n", .{mean(f64, &array3)});
}

test "median test" {
    var array1 = [_]f32{ 1.1, 5.1 };
    var array2 = [_]f64{ 1, 5, 10, 11, 15, 17 };

    std.debug.print("Median: {d:.2}\n", .{median(f32, &array1)});
    std.debug.print("Median: {d:.2}\n", .{median(f64, &array2)});
}

test "range test" {
    var array1 = [_]i64{ 1, 5, 10, 15, 17 };
    var array2 = [_]f64{ 1, 5, 10, 15, 17 };

    std.debug.print("Range: {d}\n", .{range(i64, &array1)});
    std.debug.print("Range: {d:.2}\n", .{range(f64, &array2)});
}

test "mode test" {
    var array1 = [_]f64{ 1, 5, 5, 5, 10, 15, 17 };
    var array2 = [_]i32{ 8, 9, 6, 5, 5, 5, 2, 3, 3, 3, 2, 5, 4, 78, 3, 7, 7, 7 };

    std.debug.print("Mode: {d:.2}\n", .{mode(f64, &array1)});
    std.debug.print("Mode: {d:.2}\n", .{mode(i32, &array2)});
}

test "sort test" {
    var array1 = [_]f64{ 1, 5, 8, 7, 8 };
    var array2 = [_]i32{ 8, 9, 6, 5, 5, 5, 2, 3, 3, 3, 2, 5, 4, 78, 7, 7, 7 };
    std.debug.print("Sorted: {any}\n", .{sort(f64, &array1)});
    std.debug.print("Sorted: {any}\n", .{sort(i32, &array2)});
}

test "using an allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const array1 = [_]i64{ 1, 2, 3, 5 };
    const result = try intToFloatArray(allocator, i64, &array1);
    std.debug.print("Result: {any}\n", .{result});
    defer allocator.free(result);
}

fn intToFloatArray(allocator: Allocator, comptime T: type, array: []const T) ![]f32 {
    const result = try allocator.alloc(f32, array.len);

    for (array) |value, index| {
        result[index] = @intToFloat(f32, value);
    }
    return result;
}

test "test distinct" {
    var array = [_]i64{ 1, 2, 3, 5, 5, 5, 5, 5, 5, 5 };
    _ = array;
    // const array2 = [_]f64{ 1, 2, 3, 5, 5, 5, 5, 5, 5, 5 };

    // std.debug.print("Distinct: {any}\n", .{distinct(i64, &array1)});
    // std.debug.print("Distinct: {any}\n", .{distinct(f64, &array2)});
    // std.debug.print("Distinct: {any}\n", .{distinct(f64, &array3)});

    // var list = std.ArrayList(i64).init(std.heap.page_allocator);
    // defer list.deinit();
    // const sorted = sort(i64, &array);
    //
    // var current = array[0];
    // try list.append(current);
    // for (sorted) |value| {
    //     if (value != current) {
    //         current = value;
    //         try list.append(current);
    //     }
    // }
    //
    // std.debug.print("Distinct: {any}\n", .{list.items});
    // std.debug.print("Type : {any}\n", .{@TypeOf(list)});

    // try distinct(i64, &array, std.heap.page_allocator);

    // const result = try distinct(i64, &array, std.heap.page_allocator);
    // std.debug.print("Distinct: {any}\n", .{result});
}

test "test vector" {
    var list = std.ArrayList(i32).init(std.heap.page_allocator);
    defer list.deinit();

    // std.debug.print("List type: {s}\n", .{@typeName(@TypeOf(list))});

    // const result1 = try withList(i32, list);
    // std.debug.print("With List: {any}\n", .{result1});

    const result2 = try isReturn(i32, std.heap.page_allocator);
    std.debug.print("With Allocator: {any}\n", .{result2});
}
