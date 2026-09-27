#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
libdecor_commit=815c971f73a95b6be5f5c14f65ea6d21957d7bd4
prefix=${SPIRULA_LIBDECOR_PREFIX:-"$HOME/.local/opt/spirula-libdecor"}
spirula_binary=${1:-$(command -v spirula || true)}

if [[ -z "$spirula_binary" || ! -x "$spirula_binary" ]]; then
    echo "Usage: $0 /path/to/spirula" >&2
    exit 2
fi
for command_name in git meson ninja; do
    command -v "$command_name" >/dev/null || {
        echo "Missing build tool: $command_name" >&2
        exit 2
    }
done

spirula_binary=$(realpath -- "$spirula_binary")
prefix=$(realpath -m -- "$prefix")
build_root=$(mktemp -d)
trap 'rm -rf -- "$build_root"' EXIT

git clone --quiet https://gitlab.freedesktop.org/libdecor/libdecor.git "$build_root/libdecor"
git -C "$build_root/libdecor" checkout --quiet "$libdecor_commit"
git -C "$build_root/libdecor" apply "$repo_root/tools/wayland/libdecor-resize.patch"

meson setup "$build_root/build" "$build_root/libdecor" \
    --prefix="$prefix" --libdir=lib -Ddemo=false -Dgtk=enabled
meson compile -C "$build_root/build"
meson install -C "$build_root/build"

mkdir -p -- "$prefix/bin"
wrapper="$prefix/bin/spirula-wayland"
{
    printf '#!/usr/bin/env bash\nset -euo pipefail\n'
    printf 'libdir=%q\n' "$prefix/lib"
    printf 'binary=%q\n' "$spirula_binary"
    printf 'export LD_LIBRARY_PATH="$libdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"\n'
    printf 'export LIBDECOR_PLUGIN_DIR="$libdir/libdecor/plugins-1"\n'
    printf 'exec "$binary" "$@"\n'
} > "$wrapper"
chmod +x -- "$wrapper"
printf 'Installed: %s\nUse this path in the Spirula desktop launcher Exec line.\n' "$wrapper"
