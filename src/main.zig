const std = @import("std");
const State = @import("state.zig").State;
const Error = @import("error.zig").Error;

const sdl = @cImport(@cInclude("SDL3/SDL.h"));

pub fn main() !void {
    var state = try State.init("/Users/tushar/Downloads/bc_test.ch8");
    defer state.deinit();

    var event: sdl.SDL_Event = undefined;

    main_loop: while (true) {
        while (sdl.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :main_loop,
                else => {
                    std.debug.print("EVENT: {}\n", .{event.type});
                },
            }
        }

        const inst = try state.fetch();

        std.debug.print("instruction: {}\n", .{inst});
        try state.execute(inst);

        sdl.SDL_Delay(10);
    }
}
