-- Placeholders for default foreground and background color settings
FG_PLACEHOLDER = '__FG__'
BG_PLACEHOLDER = '__BG__'

-- default options
settings = {
	--[=[ mouse zone settings ]=]--
	-- Height of area at the bottom of the screen that expands the bar and
	-- shows times when mouse is hovered over it. Pixels.
	'hover-zone-height': 40
	-- The height of the area at the top of the screen that shows the file
	-- name when the mouse is hovered over it. Pixels.
	'top-hover-zone-height': 40

	--[=[ default color settings ]=]--
	-- Default foreground and background colors. Will be used for all color
	-- settings (except chapter-marker-before) unless set explicitly.
	-- Format is BGR hex because ASS is dumb.
	'foreground': 'FC799E'
	'background': '2D2D2D'

	--[=[ progress bar options ]=]--
	-- whether or not to draw the progress bar at all.
	'enable-bar': true
	-- Hide elements even when they are inactive.
	'hide-inactive': false
	-- [[ bar size options ]] --
	-- Inactive bar height. Pixels. Bar is invisible when inactive if 0.
	'bar-height-inactive': 2
	-- Active (i.e. hovered) bar height. Pixels.
	'bar-height-active': 8
	-- [[ click-seek precision ]] --
	-- Affects precision of seeks due to clicks on the progress bar. Must
	-- be 'exact' or 'keyframes'.
	'seek-precision': 'exact'
	-- [[ bar color options ]] --
	-- Progress bar foreground color. BGR hex.
	'bar-foreground': FG_PLACEHOLDER
	'bar-cache-color': '444444'
	'bar-background': BG_PLACEHOLDER

	--[=[ elapsed time options ]=]--
	'enable-elapsed-time': true
	-- Elapsed time foreground and background colors. BGR hex.
	'elapsed-foreground': FG_PLACEHOLDER
	'elapsed-background': BG_PLACEHOLDER
	-- margins
	'elapsed-left-margin': 2
	-- This is actually added on top of the height of the progress bar.
	'elapsed-bottom-margin': 0

	--[=[ remaining time options ]=]--
	'enable-remaining-time': true
	-- Remaining time foreground and background colors. BGR hex.
	'remaining-foreground': FG_PLACEHOLDER
	'remaining-background': BG_PLACEHOLDER
	-- margins
	'remaining-right-margin': 4
	-- This is actually added on top of the height of the progress bar.
	'remaining-bottom-margin': 0

	--[=[ hover time options ]=]--
	'enable-hover-time': true
	-- Hover time foreground and background colors. BGR hex.
	'hover-time-foreground': FG_PLACEHOLDER
	'hover-time-background': BG_PLACEHOLDER
	-- margins
	'hover-time-left-margin': 120
	'hover-time-right-margin': 130
	-- This is actually added on top of the height of the progress bar.
	'hover-time-bottom-margin': 0

	--[=[ title display options ]=]--
	'enable-title': true
	-- margins
	'title-left-margin': 4
	'title-top-margin': 0
	-- Font size for the title. Integer.
	'title-font-size': 30
	-- Title/playlist foreground and background colors. BGR hex.
	'title-foreground': FG_PLACEHOLDER
	'title-background': BG_PLACEHOLDER

	--[=[ pause indicator options ]=]--
	-- Flash an icon in the center of the screen when pausing/unpausing.
	'pause-indicator': true
	-- Pause indicator foreground and background colors. BGR hex.
	'pause-indicator-foreground': FG_PLACEHOLDER
	'pause-indicator-background': BG_PLACEHOLDER

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

	--[=[ /!\ FONT SIZE/METRICS STUFF. CHANGE AT YOUR OWN RISK /!\ ]=]--
	-- Font for displaying the title and times. Changing this may warrant
	-- modifying some of the font metrics numbers below for proper
	-- display. Not recommended.
	'font': 'Source Sans Pro Semibold'
	-- Font size for time elapsed and remaining.
	'time-font-size': 30
	-- Font size for hover time.
	'hover-time-font-size': 26
	-- These primarily affect animations. If the script thinks the items
	-- are off screen, they won't be drawn. Positive numbers will look
	-- goofy.
	'elapsed-offscreen-pos': -100
	'remaining-offscreen-pos': -100
	'title-offscreen-pos': -40
}

options.read_options settings, script_name

-- Post-process settings and replace placeholder
-- values with their base color pendants
for key, value in pairs settings
	if key\match('-foreground') or key == 'chapter-marker-before'
		if value == FG_PLACEHOLDER
			settings[key] = settings.foreground
	elseif key\match('-background') or key == 'chapter-marker-after'
		if value == BG_PLACEHOLDER
			settings[key] = settings.background
