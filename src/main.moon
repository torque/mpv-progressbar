eventLoop = EventLoop!
-- This is kind of ugly but I have gone insane and don't care any more.
-- Watch the rapidly declining quality of this codebase in realtime.
local chapters, progressBar, barCache, barBackground, elapsedTime, remainingTime, hoverTime

if settings['enable-bar']
	progressBar = ProgressBar!
	barCache = ProgressBarCache!
	barBackground = ProgressBarBackground!
	eventLoop\addSubscriber barBackground
	eventLoop\addSubscriber progressBar
	eventLoop\addSubscriber barCache

	mp.add_key_binding "mouse_btn0", "seek-to-mouse", ->
		x, y = mp.get_mouse_pos!
		mp.add_timeout 0.001, ->
			if not eventLoop.inputState.mouseDead and progressBar.zone\containsPoint x, y
				mp.commandv "seek", x*100/progressBar.zone.w, "absolute-percent+#{settings['seek-precision']}"

	mp.add_key_binding "c", "toggle-inactive-bar", ->
		eventLoop\toggleInactiveVisibility!

if settings['enable-chapter-markers']
	chapters = Chapters!
	eventLoop\addSubscriber chapters

if settings['enable-elapsed-time']
	elapsedTime = TimeElapsed!
	eventLoop\addSubscriber elapsedTime

if settings['enable-remaining-time']
	remainingTime = TimeRemaining!
	eventLoop\addSubscriber remainingTime

if settings['enable-hover-time']
	hoverTime = HoverTime!
	eventLoop\addSubscriber hoverTime

playlist = nil
if settings['enable-title']
	playlist = Playlist!
	eventLoop\addSubscriber playlist

if settings['enable-system-time']
	systemTime = SystemTime!
	eventLoop\addSubscriber systemTime

notFrameStepping = false
if settings['pause-indicator']
	PauseIndicatorWrapper = ( event, paused ) ->
		if notFrameStepping
			PauseIndicator eventLoop, paused
		else
			if paused
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
	width, height = mp.get_osd_size!
	if chapters
		chapters\createMarkers width, height
	if playlist
		playlist\updatePlaylistInfo!
	notFrameStepping = true
	-- duration is nil for streams of indeterminate length
	duration = mp.get_property 'duration'
	if not (streamMode or duration)
		if progressBar
			eventLoop\removeSubscriber progressBar.index
			eventLoop\removeSubscriber barCache.index
			eventLoop\removeSubscriber barBackground.index
		if chapters
			eventLoop\removeSubscriber chapters.index
		if hoverTime
			eventLoop\removeSubscriber hoverTime.index
		if remainingTime
			eventLoop\removeSubscriber remainingTime.index
		if elapsedTime
			elapsedTime\changeBarSize 0
			eventLoop\forceResize!
		streamMode = true
	elseif streamMode and duration
		if progressBar
			eventLoop\addSubscriber barBackground
			eventLoop\addSubscriber barCache
			eventLoop\addSubscriber progressBar
		if chapters
			eventLoop\addSubscriber chapters
		if hoverTime
			eventLoop\addSubscriber hoverTime
		if remainingTime
			eventLoop\addSubscriber remainingTime
		if elapsedTime
			elapsedTime\changeBarSize settings['bar-height-active']
		eventLoop\forceResize!
		streamMode = false

	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
