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

pub fn mean(comptime T: type, array: []const T) T{
    return switch (T) {
        f32 => meanFloat(f32,array),
        f64 => meanFloat(f64,array),
        else => @compileError("Mean not implemented for " ++ @typeName(T)),
    };
}

pub fn median(comptime T: type, array: []T) T {
    return switch (T) {
        f32 => medianFloat(f32,array),
        f64 => medianFloat(f64,array),
        else => @compileError("Median not implemented for " ++ @typeName(T)),
    };
}

fn medianFloat(comptime T: type, array: []T) T {
    sort(T, array);
    return if (array.len % 2 == 1) array[array.len / 2]
            else (array[array.len / 2] + array[array.len / 2 - 1]) / 2;
}

fn meanFloat(comptime T : type, array: []const T) T {
    return sum(T, array) / @intToFloat(T, array.len);
}

fn sort(comptime T : type, array: []T) void{

    var i : usize = 0;
    while(i < array.len - 1) : (i += 1) {
        var min_idx = i;
        var j = i + 1;
        while(j < array.len) : (j += 1) {
            if (array[j] < array[min_idx]) {
                array[min_idx] = array[j];
            }
        }
        if (min_idx != i) {
            swap(T, array, i, min_idx);
        }
    }
}

fn swap(comptime T : type, array: []T, i: usize, j: usize) void {
    const temp = array[i];
    array[i] = array[j];
    array[j] = temp;
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

test "median test"{
    var array1 = [_]f32{ 1.1, 5.1 };
    var array2 = [_]f64{ 1, 5, 10, 15, 17};

    std.debug.print("Median: {d:.2}\n", .{median(f32, &array1)});
    std.debug.print("Median: {d:.2}\n", .{median(f64, &array2)});
}

test "sort test" {
    var array = [_]f64{ 1, 5,8,7,8};
    // sort(f64, &array);
    // std.debug.print("Sorted: {any}\n", .{array});
    var i : usize = 0;
    while(i < array.len - 1) : (i += 1) {
        var min_idx = i;
        var j = i + 1;
        while(j < array.len) : (j += 1) {
            if (array[j] < array[min_idx]) {
                array[min_idx] = array[j];
            }
        }
        if (min_idx != i) {
            const temp = array[i];
            array[i] = array[min_idx];
            array[min_idx] = temp;
        }
    }

    std.debug.print("Sorted: {any}\n", .{array});
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

fn intToFloatArray(allocator: Allocator,comptime T: type, array: []const T) ![]f32 {

    const result = try allocator.alloc(f32, array.len);

    for (array) |value, index| {
        result[index] = @intToFloat(f32, value);
    }
    return result;
}
