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
        "-fno-sanitize=undefined,memory,address,safe-stack",
        "-DBOTLIB"
    };

    const lib = b.addStaticLibrary("botlib", null);
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
    "be_aas_bspq3.c",
    "be_aas_cluster.c",
    "be_aas_debug.c",
    "be_aas_entity.c",
    "be_aas_file.c",
    "be_aas_main.c",
    "be_aas_move.c",
    "be_aas_optimize.c",
    "be_aas_reach.c",
    "be_aas_route.c",
    "be_aas_routealt.c",
    "be_aas_sample.c",
    "be_ai_char.c",
    "be_ai_chat.c",
    "be_ai_gen.c",
    "be_ai_goal.c",
    "be_ai_move.c",
    "be_ai_weap.c",
    "be_ai_weight.c",
    "be_ea.c",
    "be_interface.c",
    "l_crc.c",
    "l_libvar.c",
    "l_log.c",
    "l_memory.c",
    "l_precomp.c",
    "l_script.c",
    "l_struct.c",
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