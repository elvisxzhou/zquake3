const std = @import("std");
//const sdlbuild = @import("deps/zig-sdl/build.zig");
// const lua = @import("deps/lua-5.1.5/build.zig");
// const cgame = @import("src/cgame/build.zig");
// const game = @import("src/game/build.zig");
// const ui = @import("src/ui/build.zig");
const botlibBuild = @import("code/botlib/build.zig");
const rendererBuild = @import("code/renderer/build.zig");
const cgameBuild = @import("code/cgame/build.zig");
const qagameBuild = @import("code/game/build.zig");
const uiBuild = @import("code/q3_ui/build.zig");
const Target = std.zig.CrossTarget;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const cflags = &[_][]const u8{
        "-DC_ONLY",
        "-DDLL_ONLY",
        "-DWIN32",
        "-fno-sanitize=undefined,memory,address,safe-stack"
    };

    b.lib_dir = "./";
    b.exe_dir = "./";

    const exe = b.addExecutable("zquake3", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);

    const src_path = thisDir() ++ "/code";
    for (generic_src_files) |src_file| {
        exe.addCSourceFile(b.fmt("{s}/{s}", .{src_path, src_file}), cflags);
    }
    exe.addIncludePath(src_path);
    exe.addIncludePath("code/shared");

    const botlib = botlibBuild.getLibrary(b, mode, target);
    botlib.install();
    exe.linkLibrary(botlib);

    const renderer = rendererBuild.getLibrary(b, mode, target);
    renderer.install();
    exe.linkLibrary(renderer);

    const cgamelib = cgameBuild.getLibrary(b, mode, target);
    cgamelib.install();
    exe.step.dependOn(&cgamelib.step);
    const qagamelib = qagameBuild.getLibrary(b, mode, target);
    qagamelib.install();
    exe.step.dependOn(&qagamelib.step);
    const uilib = uiBuild.getLibrary(b, mode, target);
    uilib.install();
    exe.step.dependOn(&uilib.step);

    // const cgamelib = cgame.getLibrary(b, mode, target);
    // cgamelib.install();

    // const gamelib = game.getLibrary(b, mode, target);
    // gamelib.install();

    // const uilib = ui.getLibrary(b, mode, target);
    // uilib.install();
    
    exe.linkSystemLibrary("c");
    //exe.linkSystemLibrary("OpenAL32");

    if (target.isWindows()) {
        // exe.linkSystemLibrary("SDL2");
        // exe.linkSystemLibrary("SDL2main");
        exe.linkSystemLibrary("winmm");
        // exe.linkSystemLibrary("wsock32");
        exe.linkSystemLibrary("opengl32");
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("ole32");
        // exe.linkSystemLibrary("advapi32");
        exe.linkSystemLibrary("ws2_32");
        // exe.linkSystemLibrary("Psapi");
    }
    exe.install();


    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // const exe_tests = b.addTest("src/main.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}

const generic_src_files = [_][]const u8{
    "client/cl_cgame.c",
    "client/cl_cin.c",
    "client/cl_console.c",
    "client/cl_input.c",
    "client/cl_keys.c",
    "client/cl_main.c",
    "client/cl_net_chan.c",
    "client/cl_parse.c",
    "client/cl_scrn.c",
    "client/cl_ui.c",
    "qcommon/cm_load.c",
    "qcommon/cm_patch.c",
    "qcommon/cm_polylib.c",
    "qcommon/cm_test.c",
    "qcommon/cm_trace.c",
    "qcommon/cmd.c",
    "qcommon/common.c",
    "qcommon/cvar.c",
    "qcommon/files.c",
    "qcommon/huffman.c",
    "qcommon/md4.c",
    "qcommon/msg.c",
    "qcommon/net_chan.c",
    "game/q_math.c",
    "game/q_shared.c",
    "client/snd_adpcm.c",
    "client/snd_dma.c",
    "client/snd_mem.c",
    "client/snd_mix.c",
    "client/snd_wavelet.c",
    "server/sv_bot.c",
    "server/sv_ccmds.c",
    "server/sv_client.c",
    "server/sv_game.c",
    "server/sv_init.c",
    "server/sv_main.c",
    "server/sv_net_chan.c",
    "server/sv_snapshot.c",
    "server/sv_world.c",
    "qcommon/unzip.c",
    "qcommon/vm.c",
    //"qcommon/vm_interpreted.c",
    //"qcommon/vm_x86.c",
    "win32/win_input.c",
    "win32/win_main.c",
    "win32/win_net.c",
    "win32/win_shared.c",
    "win32/win_snd.c",
    "win32/win_syscon.c",
    "win32/win_wndproc.c",
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}