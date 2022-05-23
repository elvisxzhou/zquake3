const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const path = std.fs.path;
const Target = std.zig.CrossTarget;

pub const Options = struct {
    artifact: *std.build.LibExeObjStep,
    prefix: []const u8 = ".",
    override_mode: ?std.builtin.Mode = null,
};

pub fn linkArtifact(b: *Builder, options: Options) void {
    const mode = options.override_mode orelse options.artifact.build_mode;
    const lib = getLibrary(b, mode, options.artifact.target);
    options.artifact.linkLibrary(lib);
}

pub fn getLibrary(
    b: *Builder,
    mode: std.builtin.Mode,
    target: Target,
) *std.build.LibExeObjStep {

    const lib_cflags = &[_][]const u8{
        "-DC_ONLY",
        "-fno-sanitize=undefined,memory,address,safe-stack"
    };

    const lib = b.addSharedLibrary("cgamex86", null, .{ .unversioned = undefined });
    lib.setBuildMode(mode);
    lib.setTarget(target);

    lib.addIncludePath("../game");

    lib.linkSystemLibrary("c");
    const src_path = thisDir();
    for (generic_src_files) |src_file| {
        lib.addCSourceFile(b.fmt("{s}/{s}", .{src_path, src_file}), lib_cflags);
    }

    if (target.isWindows()) {
        for (windows_src_files) |src_file| {
            lib.addCSourceFile(src_file, lib_cflags);
        }
    } else if (target.isDarwin()) {
        for (darwin_src_files) |src_file| {
            lib.addCSourceFile(src_file, lib_cflags);
        }
    }
    return lib;
}

const generic_src_files = [_][]const u8{
    "../game/bg_lib.c",
    "../game/bg_misc.c",
    "../game/bg_pmove.c",
    "../game/bg_slidemove.c",
    "cg_consolecmds.c",
    "cg_draw.c",
    "cg_drawtools.c",
    "cg_effects.c",
    "cg_ents.c",
    "cg_event.c",
    "cg_info.c",
    "cg_localents.c",
    "cg_main.c",
    "cg_marks.c",
    //"cg_newDraw.c",
    "cg_players.c",
    "cg_playerstate.c",
    "cg_predict.c",
    "cg_scoreboard.c",
    "cg_servercmds.c",
    "cg_snapshot.c",
    "cg_syscalls.c",
    "cg_view.c",
    "cg_weapons.c",
    "../game/q_math.c",
    "../game/q_shared.c",
    "../ui/ui_shared.c",
};

const linux_src_files = [_][]const u8{
};

const windows_src_files = [_][]const u8{
};

const darwin_src_files = [_][]const u8{
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}