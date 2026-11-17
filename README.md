# fheroes2 on PeOS (Heroes of Might and Magic II)

The port of [fheroes2](https://github.com/ihhub/fheroes2), the free
engine of *Heroes of Might and Magic II*, to
[PeOS](https://github.com/teddi201252). It plays the game with **your own**
copy of Heroes II (GOG or CD), or with 3DO's free demo.

**State** (2026-11-18): `fheroes2.app` plays the demo on PeOS (in QEMU,
no GPU needed): a new game, turns, a save, quit, and the save loaded after
opening it again.

How it gets your game: put the game's folder (the one with `DATA`, and
`MAPS`, `MUSIC`, `ANIM` if you have them) on a USB stick, or in `/home`.
On its first start fheroes2 finds `DATA/HEROES2.AGG` there (in the
stick's top folder, or one or two folders down) and copies the game to
`/starlight/config/fheroes2`, where its settings and saves also go. From
then on the stick is not needed.

How to build it: [docs/BUILDING.md](docs/BUILDING.md).

| File or folder | What it is |
| --- | --- |
| `build.sh` | fetches fheroes2 at a fixed commit, patches it, builds it with CMake (the translations need `msgfmt`, gettext); `app` makes `fheroes2.app`; `demo` fetches the free demo (SHA-256) for tests; `stick [folder]` puts a game's folder on a FAT32 stick image for QEMU |
| `app/app.ini` | the Starlight bundle's description: capabilities and the folders it may read |
| `patches/0001-peos.patch` | SDL's software renderer on PeOS (no GPU needed); file lookup that starts from the folders an app may read; the copy of your game on the first start; a log line for each save and load |
| `tests/` | the test bundle and its steps (`make test-fheroes2` in PeOS) |
| `docs/BUILDING.md` | how to build it with a PeOS checkout, and try it in QEMU |

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
