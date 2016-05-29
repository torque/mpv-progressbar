aggregator = OSDAggregator!

animationQueue = AnimationQueue aggregator

if settings['enable-bar']
	progressBar = ProgressBar animationQueue
	aggregator\addSubscriber ProgressBarBackground animationQueue
	aggregator\addSubscriber progressBar

	mp.add_key_binding "mouse_btn0", "seek-to-mouse", ->
		x, y = mp.get_mouse_pos!
		mp.add_timeout 0.001, ->
			if not aggregator.inputState.mouseDead and progressBar\containsPoint x, y
				mp.commandv "seek", x*100/progressBar.w, "absolute-percent+#{settings['seek-precision']}"

chapters = nil
if settings['enable-chapter-markers']
	chapters = Chapters animationQueue
	aggregator\addSubscriber chapters

if settings['enable-elapsed-time']
	aggregator\addSubscriber TimeElapsed animationQueue

if settings['enable-remaining-time']
	aggregator\addSubscriber TimeRemaining animationQueue

if settings['enable-hover-time']
	aggregator\addSubscriber HoverTime animationQueue

playlist = nil
if settings['enable-title']
	playlist = Playlist animationQueue
	aggregator\addSubscriber playlist

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

initDraw = ->
	mp.unregister_event initDraw
	width, height = mp.get_osd_size!
	if chapters
		chapters\createMarkers width, height
	if playlist
		playlist\updatePlaylistInfo!

	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
