const std = @import("std");
const Error = @import("error.zig").Error;

const sdl = @cImport(@cInclude("SDL3/SDL.h"));

pub fn initSDL() !void {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.log.err("Unable to initialize SDL: {s}\n", .{sdl.SDL_GetError()});
        return Error.SDLInitializationFailed;
    }
}

pub fn deinitSDL() void {
    sdl.SDL_Quit();
}