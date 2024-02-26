
# Generic Space Shooter!

### Whats the deal?

Have been hearing bits about `Odin` recently, and always wanted to try my hand at a little game dev, so I thought a generic space shootem up would be a decent project to get my hands dirty.

Planning on exclusively using Odin's `core` and `vendor:SDL2` libraries (plus a couple terrible homebrew sprites) to build a game from scratch.

*Update:*  Adding one more dependency: `ImGUI` (see `https://gitlab.com/L-4/odin-imgui/` for the odin specific bindings).  When I started looking into rendering text (fonts) and managing GUI stacks, I found all kinds of info pointing at `ImGUI` as more or less a gold standard for game UIs (from indie to AAA, tooling and more). So I figured the fact it is so widely used, seems like compelling argument for giving it a try, and getting some experience with how it works.


## Trying it yourself:

I'm developing on macos, so directions are specifically for macos users, however directions for other platforms should be _very_ similar (just replace `brew` specifics with your platform's package manager).

 * Install Odin: `https://odin-lang.org/docs/install/`
    * Note: At the time I installed `odin`, I needed `LLVM@13` to get things working properly (slightly different than directions from the website at that time), so just be prepared to make tweaks as needed, if needed.
 * Install SDL2:
    * `brew install sdl2`
    * `brew install sdl2_image` (PNG support)
* setup odin bindings for ImGUI:
    * checkout and build ImGUI
        * checkout: `git clone https://gitlab.com/L-4/odin-imgui.git`
        * modify `build.py` to just use our SDL2 backend (set `wanted_backends = ["sdl2", "sdlrenderer2"]`)
        * install the `ply` dependency `python3 -m pip install ply`
        * build:  `python3 ./build.py`
    * symlink into your `Odin/shared` library directory (`ln -s your/path/to/odin-imgui your/path/to/Odin/shared/odin-imgui`)
* Clone this repo `git clone https://github.com/ERobsham/generic-space-shooter.git`
* Run the game! (from root level of this repo)
    * `odin run .`



# Quick overview:

#### Rough Source Structuring

Still heavily a work in progress, but as of this readme update:
```
 | generic-space-shooter.odin
 |   main entrypoint, sets up SDL2, creates the main window and runs the 'game loop'
 | 
 | /lib
 |   anything that seems like its a decent abstraction that could be useful in another game...
 |   direction / movement definitions, bounding box collisions, delta time calculation, etc
 |
 | /space_shooter
 |   specific logic for _this_ game...  player controller, enemy behaviors,
 |   general game state, etc, etc
```

Trying to set things up so each type of entity can manage their own behaviors to keep the logic as straight forward as possible. 

Most things are implemented just to 'get it working' at first, then I take a second pass and try to clean things up a bit if possible.
