eventLoop = EventLoop!
activeHeight = settings['hover-zone-height']

ignoreRequestDisplay = =>
	unless Mouse.inWindow
		return false
	if Mouse.dead
		return false
	return @containsPoint Mouse.x, Mouse.y

bottomZone = ActivityZone =>
	@reset 0, Window.h - activeHeight, Window.w, activeHeight

hoverTimeZone = ActivityZone =>
		@reset 0, Window.h - activeHeight, Window.w, activeHeight,
	ignoreRequestDisplay

topZone = ActivityZone =>
		@reset 0, 0, Window.w, activeHeight,
	ignoreRequestDisplay


-- This is kind of ugly but I have gone insane and don't care any more.
-- Watch the rapidly declining quality of this codebase in realtime.
local chapters, progressBar, barCache, barBackground, elapsedTime, remainingTime, hoverTime

if settings['enable-bar']
	-- this order is recorded and (ab)used by BarBase and
	-- ProgressBarBackground
	progressBar = ProgressBar!
	barCache = ProgressBarCache!
	barBackground = ProgressBarBackground!
	bottomZone\addUIElement barBackground

	-- this is not runtime reconfigurable, currently
	if settings['bar-cache-position'] == 'overlay'
		bottomZone\addUIElement progressBar
		bottomZone\addUIElement barCache
	else
		bottomZone\addUIElement barCache
		bottomZone\addUIElement progressBar

	mp.add_key_binding "c", "toggle-inactive-bar", ->
		BarBase\toggleInactiveVisibility!

if settings['enable-chapter-markers']
	chapters = Chapters!
	bottomZone\addUIElement chapters

if settings['enable-elapsed-time']
	elapsedTime = TimeElapsed!
	bottomZone\addUIElement elapsedTime

if settings['enable-remaining-time']
	remainingTime = TimeRemaining!
	bottomZone\addUIElement remainingTime

if settings['enable-hover-time']
	hoverTime = HoverTime!
	hoverTimeZone\addUIElement hoverTime

title = nil
if settings['enable-title']
	title = Title!
	bottomZone\addUIElement title
	topZone\addUIElement title

if settings['enable-system-time']
	systemTime = SystemTime!
	bottomZone\addUIElement systemTime
	topZone\addUIElement systemTime

-- The order of these is important, because the order that elements are added to
-- eventLoop matters, because that controls how they are layered (first element
-- on the bottom).
eventLoop\addZone hoverTimeZone
eventLoop\addZone bottomZone
eventLoop\addZone topZone

notFrameStepping = false
if settings['pause-indicator']
	PauseIndicatorWrapper = ( event, paused ) ->
		if notFrameStepping
			PauseIndicator eventLoop, paused
		elseif paused
			notFrameStepping = true

	mp.add_key_binding '.', 'step-forward',
		->
			notFrameStepping = false
			mp.commandv 'frame_step',
		{ repeatable: true }

	mp.add_key_binding ',', 'step-backward',
		->
			notFrameStepping = false
			mp.commandv 'frame_back_step',
		{ repeatable: true }

	mp.observe_property 'pause', 'bool', PauseIndicatorWrapper

streamMode = false
initDraw = ->
	-- this forces sizing activityzones and ui elements
	if chapters
		chapters\createMarkers!
	if title
		title\_forceUpdatePlaylistInfo!
		title\print!
	notFrameStepping = true
	-- duration is nil for streams of indeterminate length
	duration = mp.get_property 'duration'
	if not (streamMode or duration)
		BarAccent.changeBarSize 0
		if progressBar
			bottomZone\removeUIElement progressBar
			bottomZone\removeUIElement barCache
			bottomZone\removeUIElement barBackground
		if chapters
			bottomZone\removeUIElement chapters
		if hoverTime
			hoverTimeZone\removeUIElement hoverTime
		if remainingTime
			bottomZone\removeUIElement remainingTime
		streamMode = true
	elseif streamMode and duration
		BarAccent.changeBarSize settings['bar-height-active']
		if progressBar
			bottomZone\addUIElement barBackground
			bottomZone\addUIElement barCache
			bottomZone\addUIElement progressBar
		if chapters
			bottomZone\addUIElement chapters
		if hoverTime
			hoverTimeZone\addUIElement hoverTime
		if remainingTime
			bottomZone\addUIElement remainingTime
		streamMode = false

	mp.command 'script-message-to osc disable-osc'
	eventLoop\generateUIFromZones!
	eventLoop\resize!
	eventLoop\redraw!

mp.register_event 'file-loaded', initDraw
