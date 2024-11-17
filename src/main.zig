const std = @import("std");
const State = @import("state.zig").State;
const Error = @import("error.zig").Error;

const sdl = @cImport(@cInclude("SDL3/SDL.h"));

pub fn main() !void {
    var state = try State.init("/Users/tushar/Downloads/5-quirks.ch8");
    defer state.deinit();

    try state.setup();

    var event: sdl.SDL_Event = undefined;

    main_loop: while (true) {
        while (sdl.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :main_loop,
                sdl.SDL_EVENT_KEY_DOWN => {
                    state.keypad.setKey(event.key.scancode);
                },
                sdl.SDL_EVENT_KEY_UP => {
                    state.keypad.unsetKey(event.key.scancode);
                },
                else => {},
            }
        }

        const inst = try state.fetch();
        try state.execute(inst);

        state.keypad.recently_set = null;
    }
}
