### mpv-progressbar

mpv-progressbar is a script for mpv that provides a small, unintrusive
progress bar that persists at the bottom of the video window. It takes
up two pixels vertically, and the width of the window horizontally:

![Normal view][normal]

When hovered with the mouse, it expands to show more information:

![Hover view][hover]

As a consequence of how mpv handles drawing the osd, this script is not
compatible with the built-in osc. If you want to use it, you should add
`osc=no` to your mpv config.

#### Installation

Place the [compiled `mpv-progressbar.lua` script][build] in your `~/.mpv/lua` or
`~/.config/mpv/lua` directory. It may be more convenient to update if
you symlink it in from somewhere else.

#### Building

You must have [moonscript][moonscript] installed (particularly `moonc`,
the compiler) and ruby. Run `./build.rb` from the root of the
repository.

[normal]: https://github.com/torque/mpv-progressbar/raw/images/normal.png
[hover]: https://github.com/torque/mpv-progressbar/raw/images/hover.png
[build]: https://raw.githubusercontent.com/torque/mpv-progressbar/build/mpv-progressbar.lua
[moonscript]: http://moonscript.org
