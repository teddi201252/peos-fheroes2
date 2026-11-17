# Building fheroes2.app

The port builds against **PeOS's tree** (private): its cross toolchain
(`x86_64-peos-gcc`, `x86_64-peos-g++`), its C library and the libraries
already ported there (SDL2 with PeOS's video and audio drivers, SDL2_mixer,
zlib).

**PeOS's own repository is private, and stays private.** What is public:
PeOS's C library and its headers, in the
[Starlight App Kit](https://github.com/teddi201252/starlight-app-kit)
(`sdk/`), and the toolchain's recipe (in
[peos-d2d](https://github.com/teddi201252/peos-d2d), `toolchain/`). The
ported libraries this port links (SDL2, SDL2_mixer, zlib) are planned to
come with the kit ("the ports' SDK"). Until they do, the build below needs
PeOS's private tree, and this repository is to read: how a C++17 game with
SDL2 and SDL2_mixer becomes a PeOS app. With PeOS's tree:

## 1. PeOS

```
cd peos
make                                         # the kernel and the system
tools/peos-toolchain/build.sh all            # the x86_64-peos toolchain and its sysroot
bash userland/ports/sdl2/build.sh all        # SDL2 with PeOS's drivers, into the sysroot
bash userland/ports/sdl2_mixer/build.sh all  # SDL2_mixer (WAV, Ogg, MP3, FLAC, MIDI with timidity)
```

and zlib in the sysroot (`userland/ports/d2decomped/build.sh fetch`, then
`deps`). If
Mesa is built after SDL2, build SDL2 and SDL2_mixer again: Mesa's sysroot
step copies PeOS's own small SDL headers over the real ones.

Inside PeOS this port is `userland/ports/fheroes2`. This repository has the
same files at its top: next to a PeOS checkout (`../peos`), or with
`PEOS_DIR`:

```
PEOS_DIR=/path/to/peos ./build.sh
```

## 2. fheroes2

Your computer needs CMake, and `msgfmt` (gettext) for the translations.

```
./build.sh fetch    # fheroes2 1.1.18 (fixed commit), with patches/0001-peos.patch
./build.sh build    # the program: fheroes2 (C++17, SDL2, SDL2_mixer)
./build.sh app      # fheroes2.app: the program, fheroes2's own files, the icon; no game in it
```

or `./build.sh` for all three. The work goes to `build/fheroes2` in the
PeOS checkout (`FHEROES2_WORK` to choose another folder); nothing is
written here.

## 3. The game

fheroes2 needs the data of *Heroes of Might and Magic II*: your own copy
(GOG or CD), or 3DO's free demo. Put the game's folder (the one with
`DATA`, and `MAPS`, `MUSIC`, `ANIM` if it has them) on a USB stick, or in
PeOS's `/home`. On its first start `fheroes2.app` finds `DATA/HEROES2.AGG`
there and copies the game to `/starlight/config/fheroes2`, where its
settings and saves also go. From then on the stick is not needed.

## 4. Trying it

In PeOS (`make` in its folder), in plain QEMU (fheroes2 draws in software:
no GPU needed):

```
./build.sh demo        # 3DO's demo from archive.org, checked by SHA-256
./build.sh stick       # the demo (or: ./build.sh stick /path/to/your/game) on a FAT32 image
make test-fheroes2     # from the dock: the copy, a new game, two turns, a save, quit, reopen, load
```

`demo` and `stick` write only into `build/fheroes2`, which stays on your
computer: the game's files are never in git, nor in an image or a package.

## Changing the patch

`fetch` clones fheroes2 into `build/fheroes2/src` (a git checkout) and
applies `patches/0001-peos.patch`. To change it, edit the sources there,
then write the patch again from git (only `src/`: the build rewrites the
translations in `files/lang`):

```
cd build/fheroes2/src && git diff -- src/ > /path/to/patches/0001-peos.patch
```
