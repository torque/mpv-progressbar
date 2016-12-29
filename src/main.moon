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
	progressBar = ProgressBar!
	barCache = ProgressBarCache!
	barBackground = ProgressBarBackground!
	bottomZone\addUIElement barBackground
	bottomZone\addUIElement barCache
	bottomZone\addUIElement progressBar

	mp.add_key_binding "c", "toggle-inactive-bar", ->
		BarBase.toggleInactiveVisibility!

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
eventLoop\addZone bottomZone
eventLoop\addZone hoverTimeZone
eventLoop\addZone topZone
eventLoop\generateUIFromZones!

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
	mp.unregister_event initDraw
	-- this forces sizing activityzones and ui elements
	if chapters
		chapters\createMarkers!
	if title
		title\updatePlaylistInfo!
	eventLoop\redraw!
	notFrameStepping = true
	-- duration is nil for streams of indeterminate length
	duration = mp.get_property 'duration'
	if not (streamMode or duration)
		BarAccent.changeBarSize 0
		if progressBar
			eventLoop\removeUIElement progressBar
			eventLoop\removeUIElement barCache
			eventLoop\removeUIElement barBackground
		if chapters
			eventLoop\removeUIElement chapters
		if hoverTime
			eventLoop\removeUIElement hoverTime
		if remainingTime
			eventLoop\removeUIElement remainingTime
		streamMode = true
	elseif streamMode and duration
		BarAccent.changeBarSize settings['bar-height-active']
		if progressBar
			eventLoop\addUIElement barBackground
			eventLoop\addUIElement barCache
			eventLoop\addUIElement progressBar
		if chapters
			eventLoop\addUIElement chapters
		if hoverTime
			eventLoop\addUIElement hoverTime
		if remainingTime
			eventLoop\addUIElement remainingTime
		streamMode = false

	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
