# Wayland resize workaround

On some Wayland desktops, manually resizing Spirula Studio can pause for seconds
inside libdecor's GTK plugin while it redraws client-side decorations. The
application's frame work is not the source of the pause.

This directory contains a patch for libdecor commit
`815c971f73a95b6be5f5c14f65ea6d21957d7bd4`. It incorporates the resize
performance patch by Alex Ballas from [libdecor issue 37][issue] and delays
shadow redraws until the interactive resize has finished. The original
libdecor license is included alongside the patch.

To build and install the patched library for Spirula alone:

```bash
bash tools/wayland/install_resize_fix.sh /path/to/spirula
```

This requires Git, Meson, Ninja, a C compiler, and libdecor's GTK 3 and Wayland
development dependencies. No administrator privileges are needed. The script
installs under `~/.local/opt/spirula-libdecor` by default and prints the path
to a launcher wrapper. Set the desktop file's `Exec=` to that wrapper path to
use the fix from the application menu. Other programs continue using their
normal libdecor installation. Set `SPIRULA_LIBDECOR_PREFIX` to choose another
installation directory.

This is an opt-in workaround until the corresponding fix is available in
system libdecor packages. It has no effect on Windows or macOS builds.

[issue]: https://gitlab.freedesktop.org/libdecor/libdecor/-/issues/37
