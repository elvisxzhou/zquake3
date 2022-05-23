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

    const lib = b.addSharedLibrary("qagamex86", null, .{ .unversioned = undefined });
    lib.setBuildMode(mode);
    lib.setTarget(target);

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
    "ai_chat.c",
    "ai_cmd.c",
    "ai_dmnet.c",
    "ai_dmq3.c",
    "ai_main.c",
    "ai_team.c",
    "ai_vcmd.c",
    "bg_lib.c",
    "bg_misc.c",
    "bg_pmove.c",
    "bg_slidemove.c",
    "g_active.c",
    "g_arenas.c",
    "g_bot.c",
    "g_client.c",
    "g_cmds.c",
    "g_combat.c",
    "g_items.c",
    "g_main.c",
    "g_mem.c",
    "g_misc.c",
    "g_missile.c",
    "g_mover.c",
    "g_session.c",
    "g_spawn.c",
    "g_svcmds.c",
    "g_syscalls.c",
    "g_target.c",
    "g_team.c",
    "g_trigger.c",
    "g_utils.c",
    "g_weapon.c",
    "q_math.c",
    "q_shared.c",
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