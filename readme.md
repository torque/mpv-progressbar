### progressbar

`progressbar.lua` is a script for [mpv][mpv] that provides a small,
unintrusive progress bar that persists at the bottom of the video window
by default, though it can be configured to be hidden.

![Normal view][normal]

When hovered with the mouse, it expands to show more information:

![Hover view][hover]

As a consequence of how mpv handles drawing the osd, this script is not
compatible with the built-in osc. If you want to use it, you should add
`osc=no` to your mpv config.

#### Installation

Place the [compiled `progressbar.lua` script][build] in your
`~/.mpv/scripts` or `~/.config/mpv/scripts` directory. It may be more
convenient to update if you symlink it in from somewhere else.

#### Configuration

`progressbar.lua` has a whole host of options that can be set to change
the way it displays. These can be set on the mpv command line, but the
recommended approach is by using the configuration file
`~~/lua-settings/torque-progressbar.conf`, where `~~` is either `~/.mpv`
or `~/.config/mpv`, depending on your setup. The defaults are provided
in `settings.moon`, and are reproduced in config-file-compatible syntax
in [`torque-progressbar.conf`][conf-example].

#### Keybindings

`progressbar.lua` creates a few keybindings integral to correct script
operation. If you are running mpv with `no-input-default-bindings`,
these must be manually rebound in `~~/input.conf`. The defaults are:

```ini
. script-binding progressbar/step-forward
, script-binding progressbar/step-backward
c script-binding progressbar/toggle-inactive-bar
tab script-binding progressbar/request-display
mouse_btn0 script-binding progressbar/seek-to-mouse
```

#### Building

You must have [moonscript][moonscript] installed (particularly `moonc`,
the compiler) and GNUMake compatible make. Run `make` from the root of
the repository.

[normal]: https://github.com/torque/mpv-progressbar/raw/images/normal.png
[conf-example]: https://github.com/torque/mpv-progressbar/blob/master/torque-progressbar.conf
[hover]: https://github.com/torque/mpv-progressbar/raw/images/hover.png
[build]: https://raw.githubusercontent.com/torque/mpv-progressbar/build/progressbar.lua
[mpv]: http://mpv.io
[moonscript]: http://moonscript.org
