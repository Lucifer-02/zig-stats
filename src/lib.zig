const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

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

// ==================== Private functions ====================
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

fn sum(comptime T: type, array: []const T) T {
    var result: T = 0;
    for (array) |i| {
        result += i;
    }
    return result;
}

fn distinct(comptime T: type, array: []T, list: *ArrayList(T)) !void {
    const sorted = sort(T, array);

    var current = array[0];
    try list.append(current);
    for (sorted) |value| {
        if (value != current) {
            current = value;
            try list.append(current);
        }
    }
}

fn printArray(comptime T: type, array: []const T, message: []const u8) void {
    switch (T) {
        f16 => printFloatArray(f16, array, message),
        f32 => printFloatArray(f32, array, message),
        f64 => printFloatArray(f64, array, message),
        i8 => printIntArray(i8, array, message),
        i16 => printIntArray(i16, array, message),
        i32 => printIntArray(i32, array, message),
        i64 => printIntArray(i64, array, message),
        else => @compileError("Not support for " ++ @typeName(T)),
    }
}

fn printIntArray(comptime T: type, array: []const T, message: []const u8) void {
    std.debug.print("\n{s}", .{message});
    for (array) |value| {
        std.debug.print("{d} ", .{value});
    }
    std.debug.print("\n", .{});
}

fn printFloatArray(comptime T: type, array: []const T, message: []const u8) void {
    std.debug.print("\n{s}", .{message});
    for (array) |value| {
        std.debug.print("{d:.2} ", .{value});
    }
    std.debug.print("\n", .{});
}

test "sum test" {
    const array1 = [_]f32{ 1, 5, 2, 3, 0.2 };
    const array2 = [_]u32{ 1, 5, 2, 3 };
    try std.testing.expect(sum(f32, &array1) == 11.2);
    try std.testing.expect(sum(u32, &array2) == 11);
}

test "mean test" {
    const array1 = [_]f32{ 1.1, 5.1 };
    const array2 = [_]f64{ 1, 5, 3 };

    printArray(f32, &array1, "array1: ");
    std.debug.print("Mean: {d:.2}\n", .{mean(f32, &array1)});
    printArray(f64, &array2, "array2: ");
    std.debug.print("Mean: {d:.2}\n", .{mean(f64, &array2)});
}

test "median test" {
    var array1 = [_]f32{ 1.1, 5.1 };
    var array2 = [_]f64{ 1, 5, 10, 11, 15, 17 };

    printArray(f32, &array1, "array1: ");
    std.debug.print("Median: {d:.2}\n", .{median(f32, &array1)});
    printArray(f64, &array2, "array2: ");
    std.debug.print("Median: {d:.2}\n", .{median(f64, &array2)});
}

test "range test" {
    var array1 = [_]i64{ 1, 5, 10, 15, 17 };
    var array2 = [_]f64{ 1, 5, 10, 15, 17 };

    printArray(i64, &array1, "array1: ");
    std.debug.print("Range: {d}\n", .{range(i64, &array1)});
    printArray(f64, &array2, "array2: ");
    std.debug.print("Range: {d:.2} \n", .{range(f64, &array2)});
}

test "mode test" {
    var array1 = [_]f64{ 1, 5, 5, 5, 10, 15, 17 };
    var array2 = [_]i32{ 8, 9, 6, 5, 5, 5, 2, 3, 3, 3, 2, 5, 4, 78, 3, 7, 7, 7 };

    printArray(f64, &array1, "array1: ");
    std.debug.print("Mode: {d:.2}\n", .{mode(f64, &array1)});
    printArray(i32, &array2, "array2: ");
    std.debug.print("Mode: {d:.2}\n", .{mode(i32, &array2)});
}

test "sort test" {
    var array1 = [_]f64{ 1, 5, 8, 7, 8 };
    var array2 = [_]i32{ 8, 9, 6, 5, 5, 5, 2, 3, 3, 3, 2, 5, 4, 78, 7, 7, 7 };
    printArray(f64, &array1, "array1: ");
    std.debug.print("Sorted: {any}\n", .{sort(f64, &array1)});
    printArray(i32, &array2, "array2: ");
    std.debug.print("Sorted: {any}\n", .{sort(i32, &array2)});
}

test "test distinct" {
    var array = [_]i64{ 1, 1, 8, 9, 44, 25, 2, 3, 5, 5, 5, 5, 5, 5, 5 };

    var list = ArrayList(i64).init(std.heap.page_allocator);
    defer list.deinit();

    try distinct(i64, &array, &list);
    std.debug.print("Result: {any}\n", .{list.items});
}
