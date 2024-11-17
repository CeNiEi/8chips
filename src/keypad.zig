const std = @import("std");
const sdl = @cImport(@cInclude("SDL3/SDL.h"));
const Error = @import("error.zig").Error;

pub const Keypad = struct {
    const NUM_KEYS: usize = 16;
    keys: [NUM_KEYS]bool,

    recently_set: ?u8,

    pub fn init() Keypad {
        const keys = [_]bool{false} ** NUM_KEYS;

        return .{ .keys = keys, .recently_set = null };
    }

    pub fn isKeyDown(self: *const Keypad, key: u8) !bool {
        return self.keys[key];
    }

    pub fn setKey(self: *Keypad, scancode: sdl.SDL_Scancode) void {
        const key = scancodeToRawKey(scancode) orelse return;
        self.keys[key] = true;
    }

    pub fn unsetKey(self: *Keypad, scancode: sdl.SDL_Scancode) void {
        const key = scancodeToRawKey(scancode) orelse return;
        self.recently_set = key;
        self.keys[key] = false;
    }

    fn scancodeToRawKey(scancode: sdl.SDL_Scancode) ?u8 {
        return switch (scancode) {
            sdl.SDL_SCANCODE_X => 0x0,
            sdl.SDL_SCANCODE_1 => 0x1,
            sdl.SDL_SCANCODE_2 => 0x2,
            sdl.SDL_SCANCODE_3 => 0x3,
            sdl.SDL_SCANCODE_Q => 0x4,
            sdl.SDL_SCANCODE_W => 0x5,
            sdl.SDL_SCANCODE_E => 0x6,
            sdl.SDL_SCANCODE_A => 0x7,
            sdl.SDL_SCANCODE_S => 0x8,
            sdl.SDL_SCANCODE_D => 0x9,
            sdl.SDL_SCANCODE_Z => 0xA,
            sdl.SDL_SCANCODE_C => 0xB,
            sdl.SDL_SCANCODE_4 => 0xC,
            sdl.SDL_SCANCODE_R => 0xD,
            sdl.SDL_SCANCODE_F => 0xE,
            sdl.SDL_SCANCODE_V => 0xF,
            else => null,
        };
    }

    fn rawKeyToScancode(key: u8) !sdl.SDL_Scancode {
        return switch (key) {
            0x0 => sdl.SDL_SCANCODE_X,
            0x1 => sdl.SDL_SCANCODE_1,
            0x2 => sdl.SDL_SCANCODE_2,
            0x3 => sdl.SDL_SCANCODE_3,
            0x4 => sdl.SDL_SCANCODE_Q,
            0x5 => sdl.SDL_SCANCODE_W,
            0x6 => sdl.SDL_SCANCODE_E,
            0x7 => sdl.SDL_SCANCODE_A,
            0x8 => sdl.SDL_SCANCODE_S,
            0x9 => sdl.SDL_SCANCODE_D,
            0xA => sdl.SDL_SCANCODE_Z,
            0xB => sdl.SDL_SCANCODE_C,
            0xC => sdl.SDL_SCANCODE_4,
            0xD => sdl.SDL_SCANCODE_R,
            0xE => sdl.SDL_SCANCODE_F,
            0xF => sdl.SDL_SCANCODE_V,
            else => Error.InvalidKey,
        };
    }
};
