### progressbar

`progressbar.lua` is a script for [mpv][mpv] that provides a small,
unintrusive progress bar that persists at the bottom of the video
window. It takes up two pixels vertically, and the width of the window
horizontally:

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

`progressbar.lua` now has a whole bunch of options that can be set
either on the mpv command line or by writing the file
`~~/lua-settings/torque-progressbar.conf`, where `~~` is either `~/.mpv`
or `~/.config/mpv`, depending on your setup. The defaults are provided
in `settings.moon`, and are reproduced here in config-file-compatible
syntax.

```ini
# Font for displaying the title and times.
font=Source Sans Pro Semibold
# Font size for the title. Integer
title-font-size=30
# Font size for time elapsed and remaining.
time-font-size=30
# Font size for hover time.
hover-time-font-size=26
# Manually calculated collision/placement metrics based on font
# sizes. Probably want to change these if you change the font or
# sizes. Unfortunately, my automated solution isn't easy to set up.
# Pixels.
hover-time-left-margin=120
hover-time-right-margin=130
# These primarily affect animations. If the script thinks the items
# are off screen, they won't be drawn. Positive numbers will look
# goofy.
elapsed-offscreen-pos=-100
remaining-offscreen-pos=-100
title-offscreen-pos=-40
# Progress bar foreground color. Format is BGR hex because ASS is dumb.
bar-foreground=FC799E
bar-background=2D2D2D
# Elapsed time foreground and background colors. BGR hex.
elapsed-foreground=FC799E
elapsed-background=2D2D2D
# Remaining time foreground and background colors. BGR hex.
remaining-foreground=FC799E
remaining-background=2D2D2D
# Hover time foreground and background colors. BGR hex.
hover-time-foreground=FC799E
hover-time-background=2D2D2D
# Title/playlist foreground and background colors. BGR hex.
title-foreground=FC799E
title-background=2D2D2D
# Pause indicator foreground and background colors. BGR hex.
pause-indicator-foreground=FC799E
pause-indicator-background=2D2D2D
# Height of area that shows bar when mouse is hovered over it, in
# pixels.
hover-zone-height=40
# The height of the top hover zone, in pixels.
top-hover-zone-height=40
# Inactive bar height in pixels. Can be 0.
bar-height-inactive=2
# Active (i.e. hovered) bar height in pixels. Should probably not be
# smaller than the inactive bar height, but this isn't actually
# checked.
bar-height-active=8
# Flash an icon in the center of the screen when pausing/unpausing.
# Boolean value must be either `yes` or `no`.
pause-indicator=yes
# Amount of time (in seconds) to display OSD when key is pressed.
request-display-duration=1
# How often the display is redrawn, in seconds. Affects smoothness of
# animations, but lower values may use more CPU (the default is
# negligible on my old C2D, and looks okay to me)
redraw-period=0.03
```

#### Keybindings

`progressbar.lua` creates a few keybindings integral to correct script
operation. If you are running mpv with `no-input-default-bindings`,
these must be manually rebound in `~~/input.conf`.

```ini
. script-binding progressbar/step-forward
, script-binding progressbar/step-backward
tab script-binding progressbar/request-display
mouse_btn0 script-binding progressbar/seek-to-mouse
```

#### Building

You must have [moonscript][moonscript] installed (particularly `moonc`,
the compiler) and GNUMake compatible make. `make` from the root of the
repository.

[normal]: https://github.com/torque/mpv-progressbar/raw/images/normal.png
[hover]: https://github.com/torque/mpv-progressbar/raw/images/hover.png
[build]: https://raw.githubusercontent.com/torque/mpv-progressbar/build/progressbar.lua
[mpv]: http://mpv.io
[moonscript]: http://moonscript.org
