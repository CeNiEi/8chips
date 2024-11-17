const std = @import("std");
const sdl = @cImport(@cInclude("SDL3/SDL.h"));
const Error = @import("error.zig").Error;

pub const Timers = struct {
    delay: u8,
    sound: u8,
    mutx: *sdl.SDL_Mutex,
    // stream: *sdl.SDL_AudioStream,

    pub fn init() !Timers {
        var mutx: *sdl.SDL_Mutex = undefined;

        if (sdl.SDL_CreateMutex()) |result| {
            mutx = result;
        } else {
            std.log.err("\n[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.TimerCreationFailed;
        }

        return Timers{
            .sound = 0,
            .delay = 0,
            .mutx = mutx,
            // .stream = undefined,
        };
    }

    pub fn deinit(self: *Timers) void {
        sdl.SDL_DestroyMutex(self.mutx);
    }

    pub fn poll(self: *Timers) !void {
        if (sdl.SDL_AddTimer(16, tickTimerCallBack, @ptrCast(self)) == 0) {
            std.log.err("\n[SDL]: {s}\n", .{sdl.SDL_GetError()});
            return Error.TimerCreationFailed;
        }

        // const audio_spec = sdl.SDL_AudioSpec{
        //     .format = sdl.SDL_AUDIO_U8,
        //     .channels = 1,
        //     .freq = 44100,
        // };
        //
        // if (sdl.SDL_OpenAudioDeviceStream(
        //     sdl.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,
        //     &audio_spec,
        //     null,
        //     null,
        // )) |res| {
        //     self.stream = res;
        // } else {
        //     std.log.err("\n[SDL]: {s}\n", .{sdl.SDL_GetError()});
        //     return Error.AudioInitializationFailed;
        // }
    }

    pub fn updateDelayTimer(self: *Timers, val: u8) void {
        sdl.SDL_LockMutex(self.mutx);
        defer sdl.SDL_UnlockMutex(self.mutx);

        self.delay = val;
    }

    pub fn updateSoundTimer(self: *Timers, val: u8) void {
        sdl.SDL_LockMutex(self.mutx);
        defer sdl.SDL_UnlockMutex(self.mutx);
        self.sound = val;
    }

    pub fn getDelayTimer(self: *Timers) u8 {
        sdl.SDL_LockMutex(self.mutx);
        defer sdl.SDL_UnlockMutex(self.mutx);

        return self.delay;
    }

    pub fn tickTimerCallBack(user_data: ?*anyopaque, _: sdl.SDL_TimerID, interaval: u32) callconv(.C) u32 {
        var self: *Timers = @alignCast(@ptrCast(user_data));

        sdl.SDL_LockMutex(self.mutx);
        defer sdl.SDL_UnlockMutex(self.mutx);

        if (self.delay > 0) {
            self.delay -= 1;
        }

        if (self.sound > 0) {
            self.sound -= 1;
        } else {}

        return interaval;
    }
};
