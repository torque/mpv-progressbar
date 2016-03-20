-- default options
settings = {
	-- Font for displaying the title and times.
	font: 'Source Sans Pro Semibold'
	-- Font size for the title. Integer
	'title-font-size': 30
	-- Font size for time elapsed and remaining.
	'time-font-size': 30
	-- Font size for hover time.
	'hover-time-font-size': 26
	-- Manually calculated collision/placement metrics based on font
	-- sizes. Probably want to change these if you change the font or
	-- sizes. Unfortunately, my automated solution isn't easy to set up.
	-- Pixels.
	'hover-time-left-margin': 120
	'hover-time-right-margin': 130
	-- These primarily affect animations. If the script thinks the items
	-- are off screen, they won't be drawn. Positive numbers will look
	-- goofy.
	'elapsed-offscreen-pos': -100
	'remaining-offscreen-pos': -100
	'title-offscreen-pos': -40
	-- Progress bar foreground color. Format is BGR hex because ASS is dumb.
	'bar-foreground': 'FC799E'
	'bar-background': '2D2D2D'
	-- Elapsed time foreground and background colors. BGR hex.
	'elapsed-foreground': 'FC799E'
	'elapsed-background': '2D2D2D'
	-- Remaining time foreground and background colors. BGR hex.
	'remaining-foreground': 'FC799E'
	'remaining-background': '2D2D2D'
	-- Hover time foreground and background colors. BGR hex.
	'hover-time-foreground': 'FC799E'
	'hover-time-background': '2D2D2D'
	-- Title/playlist foreground and background colors. BGR hex.
	'title-foreground': 'FC799E'
	'title-background': '2D2D2D'
	-- Pause indicator foreground and background colors. BGR hex.
	'pause-indicator-foreground': 'FC799E'
	'pause-indicator-background': '2D2D2D'
	-- Height of area that shows bar when mouse is hovered over it, in
	-- pixels.
	'hover-zone-height': 40
	-- The height of the top hover zone, in pixels.
	'top-hover-zone-height': 40
	-- Inactive bar height in pixels. Can be 0.
	'bar-height-inactive': 2
	-- Active (i.e. hovered) bar height in pixels. Should probably not be
	-- smaller than the inactive bar height, but this isn't actually
	-- checked.
	'bar-height-active': 8
	-- Width of chapter markers in pixels. Probably want an even number.
	'chapter-marker-width': 2
	-- color of chapter marker before it has been passed. BGR hex.
	'chapter-marker-before': '7A77F2'
	-- color of chapter marker after it has been passed. BGR hex.
	'chapter-marker-after': '2D2D2D'
	-- Flash an icon in the center of the screen when pausing/unpausing.
	'pause-indicator': true
	-- Amount of time (in seconds) to display osc when button is pressed.
	'request-display-duration': 1
	-- How often the display is redrawn, in seconds. Affects smoothness of
	-- animations, but lower values may use more CPU (the default is
	-- negligible on my old C2D, and looks okay to me)
	'redraw-period': 0.03
}

options.read_options settings, script_name
