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

    const lib = b.addSharedLibrary("uix86", null, .{ .unversioned = undefined });
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
    "../game/bg_misc.c",
    "../game/q_math.c",
    "../game/q_shared.c",
    "ui_addbots.c",
    "ui_atoms.c",
    "ui_cdkey.c",
    "ui_cinematics.c",
    "ui_confirm.c",
    "ui_connect.c",
    "ui_controls2.c",
    "ui_credits.c",
    "ui_demo2.c",
    "ui_display.c",
    "ui_gameinfo.c",
    "ui_ingame.c",
    "ui_loadconfig.c",
    "ui_main.c",
    "ui_menu.c",
    "ui_mfield.c",
    "ui_mods.c",
    "ui_network.c",
    "ui_options.c",
    "ui_playermodel.c",
    "ui_players.c",
    "ui_playersettings.c",
    "ui_preferences.c",
    "ui_qmenu.c",
    "ui_removebots.c",
    "ui_saveconfig.c",
    "ui_serverinfo.c",
    "ui_servers2.c",
    "ui_setup.c",
    "ui_sound.c",
    "ui_sparena.c",
    "ui_specifyserver.c",
    "ui_splevel.c",
    "ui_sppostgame.c",
    "ui_spreset.c",
    "ui_spskill.c",
    "ui_startserver.c",
    "../ui/ui_syscalls.c",
    "ui_team.c",
    "ui_teamorders.c",
    "ui_video.c",
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