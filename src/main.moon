aggregator = OSDAggregator!
animationQueue = AnimationQueue aggregator
-- This is kind of ugly but I have gone insane and don't care any more.
-- Watch the rapidly declining quality of this codebase in realtime.
local chapters, progressBar, barBackground, elapsedTime, remainingTime, hoverTime

if settings['enable-bar']
	progressBar = ProgressBar animationQueue
	barBackground = ProgressBarBackground animationQueue
	aggregator\addSubscriber barBackground
	aggregator\addSubscriber progressBar

	mp.add_key_binding "mouse_btn0", "seek-to-mouse", ->
		x, y = mp.get_mouse_pos!
		mp.add_timeout 0.001, ->
			if not aggregator.inputState.mouseDead and progressBar.zone\containsPoint x, y
				mp.commandv "seek", x*100/progressBar.zone.w, "absolute-percent+#{settings['seek-precision']}"

	mp.add_key_binding "c", "toggle-inactive-bar", ->
		aggregator\toggleInactiveVisibility!

if settings['enable-chapter-markers']
	chapters = Chapters animationQueue
	aggregator\addSubscriber chapters

if settings['enable-elapsed-time']
	elapsedTime = TimeElapsed animationQueue
	aggregator\addSubscriber elapsedTime

if settings['enable-remaining-time']
	remainingTime = TimeRemaining animationQueue
	aggregator\addSubscriber remainingTime

if settings['enable-hover-time']
	hoverTime = HoverTime animationQueue
	aggregator\addSubscriber hoverTime

playlist = nil
if settings['enable-title']
	playlist = Playlist animationQueue
	aggregator\addSubscriber playlist

if settings['enable-system-time']
	systemTime = SystemTime animationQueue
	aggregator\addSubscriber systemTime

if settings['pause-indicator']
	notFrameStepping = false
	PauseIndicatorWrapper = ( event, paused ) ->
		if notFrameStepping
			PauseIndicator animationQueue, aggregator, paused
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
	-- duration is nil for streams of indeterminate length
	duration = mp.get_property 'duration'
	if not (streamMode or duration)
		if progressBar
			aggregator\removeSubscriber progressBar.aggregatorIndex
			aggregator\removeSubscriber barBackground.aggregatorIndex
		if chapters
			aggregator\removeSubscriber chapters.aggregatorIndex
		if hoverTime
			aggregator\removeSubscriber hoverTime.aggregatorIndex
		if remainingTime
			aggregator\removeSubscriber remainingTime.aggregatorIndex
		if elapsedTime
			elapsedTime\changeBarSize 0
			aggregator\forceResize!
		streamMode = true
	elseif streamMode and duration
		if progressBar
			aggregator\addSubscriber barBackground
			aggregator\addSubscriber progressBar
		if chapters
			aggregator\addSubscriber chapters
		if hoverTime
			aggregator\addSubscriber hoverTime
		if remainingTime
			aggregator\addSubscriber remainingTime
		if elapsedTime
			elapsedTime\changeBarSize settings['bar-height-active']
		aggregator\forceResize!
		streamMode = false

	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
