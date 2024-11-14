const std = @import("std");
const Error = @import("error.zig").Error;

const sdl = @cImport(@cInclude("SDL3/SDL.h"));

pub const Display = struct {
    pub const DISPLAY_WIDTH: usize = 64;
    pub const DISPLAY_HEIGHT: usize = 32;
    pub const SCALE: usize = 10;

    window: *sdl.SDL_Window,
    renderer: *sdl.SDL_Renderer,
    pixel_tracker: [DISPLAY_WIDTH * DISPLAY_HEIGHT]bool = .{false} ** (DISPLAY_WIDTH * DISPLAY_HEIGHT),

    pub fn init() !Display {
        var window: *sdl.SDL_Window = undefined;
        var renderer: *sdl.SDL_Renderer = undefined;

        if (sdl.SDL_CreateWindow(
            "8Chips".ptr,
            DISPLAY_WIDTH * SCALE,
            DISPLAY_HEIGHT * SCALE,
            sdl.SDL_WINDOW_ALWAYS_ON_TOP,
        )) |result| {
            window = result;
        } else {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayCreationFailed;
        }

        if (sdl.SDL_CreateRenderer(window, null)) |result| {
            if (!sdl.SDL_SetRenderLogicalPresentation(
                result,
                DISPLAY_WIDTH,
                DISPLAY_HEIGHT,
                sdl.SDL_LOGICAL_PRESENTATION_STRETCH,
            )) {
                std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
                return Error.DisplayCreationFailed;
            }
            renderer = result;
        } else {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayCreationFailed;
        }

        return .{ .window = window, .renderer = renderer };
    }

    pub fn deinit(self: *const Display) void {
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);
    }

    pub fn getPixelStatus(self: *const Display, x: usize, y: usize) bool {
        return self.pixel_tracker[y * DISPLAY_WIDTH + x];
    }

    const State = enum { set, unset };

    fn setPixelState(self: *Display, x: usize, y: usize, state: State) !void {
        const r: u8, const g: u8, const b: u8, const pixel_state: bool = switch (state) {
            .set => .{ 255, 255, 255, true },
            .unset => .{ 0, 0, 0, false },
        };

        if (!sdl.SDL_SetRenderDrawColor(self.renderer, r, g, b, sdl.SDL_ALPHA_OPAQUE)) {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayDrawingFailed;
        }

        if (!sdl.SDL_RenderPoint(self.renderer, @floatFromInt(x), @floatFromInt(y))) {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayDrawingFailed;
        }

        self.pixel_tracker[y * DISPLAY_WIDTH + x] = pixel_state;
    }

    pub fn setPixel(self: *Display, x: usize, y: usize) !void {
        return self.setPixelState(x, y, State.set);
    }

    pub fn unsetPixel(self: *Display, x: usize, y: usize) !void {
        return self.setPixelState(x, y, State.unset);
    }

    pub fn clear(self: *Display) !void {
        if (!sdl.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255)) {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayClearFailed;
        }

        if (!sdl.SDL_RenderClear(self.renderer)) {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayClearFailed;
        }

        @memset(&self.pixel_tracker, false);
    }

    pub fn flush(self: *Display) !void {
        if (!sdl.SDL_RenderPresent(self.renderer)) {
            std.log.err("[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.DisplayPresentFailed;
        }
    }
};
