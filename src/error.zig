const std = @import("std");

pub const Error = error{
    SDLInitializationFailed,
    DisplayCreationFailed,
    DisplayClearFailed,
    DisplayDrawingFailed,
    DisplayPresentFailed,
    StackEmpty,
    OutOfBounds,
    InvalidInstruction,
    TimerCreationFailed,
    AudioInitializationFailed,
    InvalidKey,
};
