### mpv-progressbar

mpv-progressbar is a script for mpv that provides a small, unintrusive
progress bar that persists at the bottom of the video window.

As a consequence of how mpv handles drawing the osd, this script is not
compatible with the built-in osc. If you want to use it, you should add
`osc=no` to your mpv config.

#### Installation

Place the compiled `mpv-progressbar.lua` script in your `~/.mpv/lua` or
`~/.config/mpv/lua` directory. It may be more convenient to update if
you symlink it in from somewhere else.
