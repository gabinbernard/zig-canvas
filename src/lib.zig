const std = @import("std");
const Canvas = @import("./Canvas.zig").Canvas;
const ColorModes = @import("./ColorModes.zig").ColorModes;

pub fn createCanvas(comptime width: u16, comptime height: u16, comptime colorMode: ColorModes, allocator: std.mem.Allocator) !Canvas(colorMode) {
    const defaultStyle = switch (colorMode) {
        .grayscale => 0xff,
        .rgb => 0xffffff,
        .rgba => 0xffffffff,
    };

    const eraseStyle = switch (colorMode) {
        .grayscale => 0x00,
        .rgb => 0x000000,
        .rgba => 0x00000000,
    };

    const byteLength = @as(u64, width) * @as(u64, height) * @intFromEnum(colorMode);
    var bytes = try allocator.alloc(u8, byteLength);

    for (0..byteLength) |i| {
        bytes[i] = 0;
    }

    return Canvas(colorMode){
        .width = width,
        .height = height,
        .colorMode = colorMode,
        .byteLength = byteLength,
        .allocator = allocator,
        .bytes = bytes,
        .fillStyle = defaultStyle,
        .strokeStyle = defaultStyle,
        .eraseStyle = eraseStyle,
    };
}
