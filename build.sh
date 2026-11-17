#!/usr/bin/env bash
# fheroes2 (Heroes of Might and Magic II's free engine, GPL-2.0) for PeOS:
# docs/game-ports-plan.md, section 5. The sources at a fixed commit under
# build/fheroes2 (never in git), PeOS's patches, CMake with the ports'
# toolchain, over SDL2 and SDL2_mixer on PeOS (userland/ports/sdl2,
# userland/ports/sdl2_mixer). The game's data are the user's: the demo
# (3DO's, from archive.org, checked by SHA-256) is fetched only for tests
# and stays in build/.
#
#   userland/ports/fheroes2/build.sh fetch   fheroes2 1.1.18, patched
#   userland/ports/fheroes2/build.sh build   the program: build/fheroes2/fheroes2
#   userland/ports/fheroes2/build.sh demo    the Heroes II demo, for make test-fheroes2
#   userland/ports/fheroes2/build.sh all     fetch and build
#
# The same script is the public copy's (the peos-fheroes2 repository, the
# port's files at its top): there PEOS_DIR names a PeOS checkout.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ -n "${PEOS_DIR:-}" ]; then
    ROOT="$(cd "$PEOS_DIR" && pwd)"
elif [ -f "$HERE/../../../kernel/main.c" ]; then
    ROOT="$(cd "$HERE/../../.." && pwd)"
else
    ROOT="$(cd "$HERE/../peos" 2>/dev/null && pwd)" || { echo "fheroes2: no PeOS checkout: set PEOS_DIR"; exit 1; }
fi
W="${FHEROES2_WORK:-$ROOT/build/fheroes2}"
SYSROOT="$ROOT/build/peos-sysroot"
JOBS="${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || nproc)}"

FH2_URL=https://github.com/ihhub/fheroes2.git
FH2_TAG=1.1.18
FH2_COMMIT=9280fe5ee3af2cfc1036a0fa1c1e69eeb1b11f59
DEMO_URL=https://archive.org/download/HeroesofMightandMagicIITheSuccessionWars_1020/h2demo.zip
DEMO_SHA256=12048c8b03875c81e69534a3813aaf6340975e77b762dc1b79a4ff5514240e3c

fetch() {
    mkdir -p "$W"
    [ -d "$W/src/.git" ] || git clone -q --depth 1 --branch "$FH2_TAG" "$FH2_URL" "$W/src"
    [ "$(git -C "$W/src" rev-parse HEAD)" = "$FH2_COMMIT" ] || { echo "fheroes2: $FH2_TAG is not $FH2_COMMIT"; exit 1; }
    git -C "$W/src" reset -q --hard && git -C "$W/src" clean -qfdx
    for p in "$HERE"/patches/*.patch; do
        patch -d "$W/src" -p1 --quiet < "$p" || { echo "fheroes2: $p does not apply"; exit 1; }
    done
    echo "fheroes2: $FH2_TAG (${FH2_COMMIT:0:8}) fetched and patched in $W/src"
}

build() {
    [ -f "$SYSROOT/usr/lib/libSDL2_mixer.a" ] || { echo "fheroes2: SDL2_mixer missing: userland/ports/sdl2/build.sh, then userland/ports/sdl2_mixer/build.sh"; exit 1; }
    [ -d "$W/src" ] || fetch
    cmake -S "$W/src" -B "$W/build" -Wno-dev \
        -DCMAKE_TOOLCHAIN_FILE="$ROOT/userland/ports/d2decomped/toolchain-peos.cmake" \
        -DCMAKE_BUILD_TYPE=Release -DUSE_SDL_VERSION=SDL2 -DENABLE_IMAGE=OFF -DENABLE_TOOLS=OFF \
        -DCMAKE_CXX_FLAGS="-I$SYSROOT/usr/include" >/dev/null
    cmake --build "$W/build" -j"$JOBS" >/dev/null
    "$ROOT/build/toolchain/peos/bin/x86_64-peos-strip" -o "$W/fheroes2" "$W/build/fheroes2"
    echo "fheroes2: $W/fheroes2 ($(du -h "$W/fheroes2" | cut -f1 | tr -d ' '))"
}

demo() {   # 3DO's free demo, for the tests only: never in git, an image or a package
    mkdir -p "$W/demo"
    [ -f "$W/demo/h2demo.zip" ] || curl -sSLf -o "$W/demo/h2demo.zip" "$DEMO_URL"
    echo "$DEMO_SHA256  $W/demo/h2demo.zip" | { if command -v shasum >/dev/null; then shasum -a 256 -c -; else sha256sum -c -; fi; } >/dev/null ||
        { echo "fheroes2: the demo's SHA-256 does not match"; exit 1; }
    mkdir -p "$W/demo/x" && unzip -q -o "$W/demo/h2demo.zip" -d "$W/demo/x"
    echo "fheroes2: the demo in $W/demo/x (DATA, MAPS)"
}

case "${1:-all}" in
    fetch) fetch ;;
    build) build ;;
    demo) demo ;;
    all) fetch; build ;;
    *) echo "usage: $0 fetch|build|demo|all"; exit 2 ;;
esac
