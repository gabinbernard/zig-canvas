const std = @import("std");
const ColorModes = @import("./ColorModes.zig").ColorModes;

pub fn Canvas(comptime colorMode: ColorModes) type {
    const styleType = comptime switch (colorMode) {
        .grayscale => u8,
        .rgb => u24,
        .rgba => u32,
    };

    return struct {
        width: u16,
        height: u16,
        colorMode: ColorModes,
        byteLength: u64,
        allocator: std.mem.Allocator,
        bytes: []u8,
        fillStyle: styleType,
        strokeStyle: styleType,
        eraseStyle: styleType,

        /// Fill the whole canvas using `self.fillStyle`
        pub fn fillCanvas(self: @This()) void {
            if (styleType == u8) {
                for (0..self.width) |xCoord| {
                    for (0..self.height) |yCoord| {
                        self.bytes[xCoord + yCoord * self.width] = @truncate(self.fillStyle);
                    }
                }
            } else if (styleType == u24) {
                for (0..self.width) |xCoord| {
                    for (0..self.height) |yCoord| {
                        self.bytes[(xCoord + yCoord * self.width) * 3] = @truncate(self.fillStyle >> 16);
                        self.bytes[(xCoord + yCoord * self.width) * 3 + 1] = @truncate(self.fillStyle >> 8 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 3 + 2] = @truncate(self.fillStyle & 0xff);
                    }
                }
            } else if (styleType == u32) {
                for (0..self.width) |xCoord| {
                    for (0..self.height) |yCoord| {
                        self.bytes[(xCoord + yCoord * self.width) * 4] = @truncate(self.fillStyle >> 24);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 1] = @truncate(self.fillStyle >> 16 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 2] = @truncate(self.fillStyle >> 8 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 3] = @truncate(self.fillStyle & 0xff);
                    }
                }
            }
        }

        /// Fill a rectangle in the canvas using `self.fillStyle`
        pub fn fillRect(self: @This(), x: u16, y: u16, w: u16, h: u16) void {
            if (x > self.width or y > self.height) return;
            if (styleType == u8) {
                for (x..x + w) |xCoord| {
                    for (y..y + h) |yCoord| {
                        self.bytes[xCoord + yCoord * self.width] = @truncate(self.fillStyle);
                    }
                }
            } else if (styleType == u24) {
                for (x..x + w) |xCoord| {
                    for (y..y + h) |yCoord| {
                        self.bytes[(xCoord + yCoord * self.width) * 3] = @truncate(self.fillStyle >> 16);
                        self.bytes[(xCoord + yCoord * self.width) * 3 + 1] = @truncate(self.fillStyle >> 8 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 3 + 2] = @truncate(self.fillStyle & 0xff);
                    }
                }
            } else if (styleType == u32) {
                for (x..x + w) |xCoord| {
                    for (y..y + h) |yCoord| {
                        self.bytes[(xCoord + yCoord * self.width) * 4] = @truncate(self.fillStyle >> 24);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 1] = @truncate(self.fillStyle >> 16 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 2] = @truncate(self.fillStyle >> 8 & 0xff);
                        self.bytes[(xCoord + yCoord * self.width) * 4 + 3] = @truncate(self.fillStyle & 0xff);
                    }
                }
            }
        }

        /// Erase the whole canvas using `self.eraseStyle`
        pub fn eraseCanvas(self: @This()) void {
            const fillStyle = self.fillStyle;
            self.fillStyle = self.eraseStyle;
            self.fillCanvas();

            self.fillStyle = fillStyle;
        }

        /// Erase a rectangle in the canvas using `self.eraseStyle`
        pub fn eraseRect(self: @This(), x: u16, y: u16, w: u16, h: u16) void {
            const fillStyle = self.fillStyle;
            self.fillStyle = self.eraseStyle;
            self.fillRect(x, y, w, h);

            self.fillStyle = fillStyle;
        }

        /// Apply the `shader` function to each byte of the canvas
        pub fn applyByteShader(comptime shader: fn (u64, u8) u8) void {
            _ = shader;
        }

        /// Apply the `shader` function to each pixel of the canvas
        pub fn applyPixelShader(comptime shader: fn (u16, u16, styleType) styleType) void {
            _ = shader;
        }

        /// Utility function to get 4 bytes from u64 (for BMP sizes)
        fn getFourBytes(n: u64) [4]u8 {
            return [_]u8{ @truncate(n & 0xff), @truncate(n >> 8 & 0xff), @truncate(n >> 16 & 0xff), @truncate(n >> 24) };
        }

        /// Save a canvas as a BMP image file
        pub fn save(self: @This(), path: []const u8) !void {
            const headerSize = 122;
            const bmpSize: u64 = @as(u64, self.width) * @as(u64, self.height) * 4 + headerSize;
            const headerSizeBytes = getFourBytes(headerSize);
            const bmpSizeBytes = getFourBytes(bmpSize);
            const widthBytes = getFourBytes(self.width);
            const heightBytes = getFourBytes(self.height);

            const cwd = std.fs.cwd();
            const bmpFile = try (cwd.createFile(path, .{ .read = true }) catch cwd.openFile(path, .{ .mode = .read_write }));
            defer bmpFile.close();

            var header = [_]u8{
                0x42, 0x4D, // BM
                bmpSizeBytes[0], bmpSizeBytes[1], // Size
                bmpSizeBytes[2], bmpSizeBytes[3],
                0x00, 0x00, // Unused
                0x00, 0x00,
                headerSizeBytes[0], headerSizeBytes[1], // Header size
                headerSizeBytes[2], headerSizeBytes[3],
                0x6C, 0x00, // DiB Header bytes length
                0x00, 0x00,
                widthBytes[0], widthBytes[1], // Width of the bitmap
                widthBytes[2], widthBytes[3],
                heightBytes[0], heightBytes[1], // Height of the bitmap
                heightBytes[2], heightBytes[3],
                0x01, 0x00, // Number of planes
                0x20, 0x00, // Number of bits per pixels
                0x03, 0x00, // BI_BITFIELDS
                0x00, 0x00,
                0x20, 0x00, // Size of the raw bitmap data
                0x00, 0x00,
                0x13, 0x0B, // Print resolution
                0x00, 0x00,
                0x13, 0x0B, // Print resolution
                0x00, 0x00,
                0x00, 0x00, // Number of colors in the palette
                0x00, 0x00,
                0x00, 0x00, // All color are important
                0x00, 0x00,
                0xff, 0x00, // Red color mask
                0x00, 0x00,
                0x00, 0xff, // Green color mask
                0x00, 0x00,
                0x00, 0x00, // Blue color mask
                0xff, 0x00,
                0x00, 0x00, // Alpha color mask
                0x00, 0xff,
                0x20, 0x6E, // LCS_WINDOWS_COLOR_SPACE
                0x69, 0x57,
                0x00, 0x00, // CIEXYZTRIPLE Color Space endpoints
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00, // Red gamma,
                0x00, 0x00,
                0x00, 0x00, // Green gamma,
                0x00, 0x00,
                0x00, 0x00, // Blue gamma,
                0x00, 0x00,
            };

            _ = try bmpFile.write(&header);

            var bmpFileSize = try bmpFile.stat();
            try bmpFile.seekTo(bmpFileSize.size);
            _ = try bmpFile.write(self.bytes);
        }
    };
}
