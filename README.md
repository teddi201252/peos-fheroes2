# fheroes2 on PeOS (Heroes of Might and Magic II)

The port of [fheroes2](https://github.com/ihhub/fheroes2), the free
engine of *Heroes of Might and Magic II*, to
[PeOS](https://github.com/teddi201252). It plays the game with **your own**
copy of Heroes II (GOG or CD), or with 3DO's free demo.

**Work in progress** (2026-11-17). Done:
- fheroes2 1.1.18 compiles and links for PeOS (C++17, `std::thread`,
  `std::filesystem`);
- it starts as a Starlight app and draws with SDL's software renderer,
  scaled to the window.

Not yet:
- run as an app, it does not find the game's data yet. Its folder lookup
  meets PeOS's per-app folder permissions;
- `fheroes2.app` with a setup that copies your game from a USB stick.

| File or folder | What it is |
| --- | --- |
| `build.sh` | fetches fheroes2 at a fixed commit, patches it, builds it with CMake; `demo` fetches the free demo (SHA-256) for tests |
| `patches/0001-peos.patch` | SDL's software renderer on PeOS (no GPU needed); file lookup that starts from the folders an app may read |
| `tests/` | the test bundle and its steps (`make test-fheroes2` in PeOS) |

What PeOS gives it, in PeOS's tree:
- `userland/ports/sdl2`: the real SDL 2.30.9 with PeOS's video and audio
  drivers;
- `userland/ports/sdl2_mixer`: SDL_mixer 2.8.2 with its own decoders (WAV,
  Ogg, MP3, FLAC, MIDI with timidity).

## License

fheroes2 is free software under the **GNU General Public License, version
2 or later**; so is this port: see [LICENSE](LICENSE).

Heroes of Might and Magic is a trademark of Ubisoft. This project is not
affiliated with or endorsed by Ubisoft or 3DO, and contains none of the
game's files: the demo is fetched from archive.org by `build.sh demo` and
stays on your computer.
