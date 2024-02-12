
# Generic Space Shooter!

### Whats the deal?

Have been hearing bits about `Odin` recently, and always wanted to try my hand at a little game dev, so I thought a generic space shootem up would be a decent project to get my hands dirty.

Planning on exclusively using Odin's `core` and `vendor:SDL2` libraries (plus a couple terrible homebrew sprites) to build a game from scratch.



## Trying it yourself:

I'm developing on macos, so directions are specifically for macos users, however directions for other platforms should be _very_ similar (just replace `brew` specifics with your platform's package manager).

 * Install Odin: `https://odin-lang.org/docs/install/`
    * Note: At the time I installed `odin`, I needed `LLVM@13` to get things working properly (slightly different than directions from the website at that time), so just be prepared to make tweaks as needed, if needed.
 * Install SDL2:
    * `brew install sdl2`
    * `brew install sdl2_image` (PNG support)
* Clone this repo `git clone https://github.com/ERobsham/generic-space-shooter.git`
* Run the game! (from root level of the repo)
    * `odin run .`