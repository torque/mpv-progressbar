-- default options
settings = {
	--[=[ mouse zone settings ]=]--
	-- Height of area at the bottom of the screen that expands the bar and
	-- shows times when mouse is hovered over it. Pixels.
	'hover-zone-height': 40
	-- The height of the area at the top of the screen that shows the file
	-- name when the mouse is hovered over it. Pixels.
	'top-hover-zone-height': 40
	-- Effectively acts as a multiplier, increasing OSC display size. This is
	-- useful for high-dpi displays, which change the relative video-resolution-
	-- to-osd-resolution ratio, at least on some platforms (macOS)
	'display-scale-factor': 1

	--[=[ Default override ]=]--
	-- Changing the font will likely require changing the hover-time margin
	-- settings and the offscreen-pos settings.
	'default-style': [[\fnSource Sans Pro\b1\bord2\fs30\c&HFC799E&\3c&H2D2D2D&]]

	--[=[ progress bar options ]=]--
	-- whether or not to draw the progress bar at all.
	'enable-bar': true
	-- Hide the bar even when it is inactive.
	'hide-inactive': false
	-- [[ bar size options ]] --
	-- Inactive bar height. Pixels. Sets `hide-inactive` to true if
	-- bar-height-inactive <= 0.
	'bar-height-inactive': 2
	-- Active (i.e. hovered) bar height. Pixels.
	'bar-height-active': 8
	-- [[ click-seek precision ]] --
	-- Affects precision of seeks due to clicks on the progress bar. Must
	-- be 'exact' or 'keyframes'.
	'seek-precision': 'exact'
	-- [[ bar color options ]] --
	-- Progress bar foreground color. BGR hex.
	'bar-default-style': [[\bord0]]
	'bar-foreground-style': ''
	'bar-cache-style': [[\c&H515151&]]
	'bar-background-style': [[\c&H2D2D2D&]]

	--[=[ elapsed time options ]=]--
	'enable-elapsed-time': true
	'elapsed-style': ''
	-- margins
	'elapsed-left-margin': 2
	-- This is actually added on top of the height of the progress bar.
	'elapsed-bottom-margin': 0

	--[=[ remaining time options ]=]--
	'enable-remaining-time': true
	'remaining-style': ''
	-- margins
	'remaining-right-margin': 4
	-- This is actually added on top of the height of the progress bar.
	'remaining-bottom-margin': 0

	--[=[ hover time options ]=]--
	'enable-hover-time': true
	'hover-time-style': [[\fs26]]
	-- margins
	'hover-time-left-margin': 120
	'hover-time-right-margin': 130
	-- This is actually added on top of the height of the progress bar.
	'hover-time-bottom-margin': 0

	--[=[ title display options ]=]--
	'enable-title': true
	-- ASS override tags for styling the title.
	'title-style': ''
	-- margins
	'title-left-margin': 4
	'title-top-margin': 0
	'title-print-to-cli': true

	--[=[ system time display options ]=]--
	'enable-system-time': true
	'system-time-style': ''
	-- This must be a strftime-compatible format string.
	'system-time-format': '%H:%M'
	-- margins
	'system-time-right-margin': 4
	'system-time-top-margin': 0
	'system-time-font-size': 30

	--[=[ pause indicator options ]=]--
	-- Flash an icon in the center of the screen when pausing/unpausing.
	'pause-indicator': true
	-- Pause indicator foreground and background colors. BGR hex.
	'pause-indicator-foreground-style': [[\c&HFC799E&]]
	'pause-indicator-background-style': [[\c&H2D2D2D&]]

	--[=[ chapter marker options ]=]--
	-- Enable or disable chapter position markers on the progress bar
	-- entirely.
	'enable-chapter-markers': true
	-- [[ chapter marker size options ]] --
	-- Width of chapter markers in pixels. Probably want an even number.
	'chapter-marker-width': 2
	-- Width of chapter markers in pixels when the seek bar is active.
	-- Still probably want an even number.
	'chapter-marker-width-active': 4
	-- Fraction of the height of the active progress bar that chapter
	-- markers. 0 is 0, 1 is the height of the active progress bar.
	'chapter-marker-active-height-fraction': 1
	-- [[ chapter marker color options ]] --
	-- color of chapter marker before/after it has been passed. BGR hex.
	'chapter-marker-before': FG_PLACEHOLDER
	'chapter-marker-after': BG_PLACEHOLDER

	--[=[ timing options ]=]--
	-- Amount of time (in seconds) to display OSD when button is pressed.
	'request-display-duration': 1
	-- How often the display is redrawn, in seconds. Affects smoothness of
	-- animations, but lower values may use more CPU (the default is
	-- negligible on my old C2D, and looks okay to me). The libass display
	-- update speed appears to be locked to the video framerate though, so
	-- even with a small value this may end up looking fairly jerky.
	'redraw-period': 0.03
	'animation-duration': 0.25

	--[=[ /!\ FONT SIZE/METRICS STUFF. CHANGE AT YOUR OWN RISK /!\ ]=]--
	-- These primarily affect animations. If the script thinks the items
	-- are off screen, they won't be drawn. Positive numbers will look
	-- goofy.
	'elapsed-offscreen-pos': -100
	'remaining-offscreen-pos': -100
	'system-time-offscreen-pos': -100
	'title-offscreen-pos': -40
}

options.read_options settings, script_name

if settings['bar-height-inactive'] <= 0
	settings['hide-inactive'] = true
	settings['bar-height-inactive'] = 1
