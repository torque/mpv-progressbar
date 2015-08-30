aggregator = OSDAggregator!

animationQueue = AnimationQueue aggregator
Bounds\instance!

progressBar           = ProgressBar animationQueue
progressBarBackground = ProgressBarBackground animationQueue
chapters              = Chapters animationQueue
timeElapsed           = TimeElapsed animationQueue
timeRemaining         = TimeRemaining animationQueue
hoverTime             = HoverTime animationQueue
playlist              = Playlist animationQueue

hoverTime.leftBound = timeElapsed.sizeCache
hoverTime.rightBound = timeRemaining.sizeCache

aggregator\addSubscriber progressBarBackground
aggregator\addSubscriber progressBar
aggregator\addSubscriber chapters
aggregator\addSubscriber timeElapsed
aggregator\addSubscriber timeRemaining
aggregator\addSubscriber hoverTime
aggregator\addSubscriber playlist

notFrameStepping = true
PauseIndicatorWrapper = ( event, paused ) ->
	if notFrameStepping
		PauseIndicator animationQueue, aggregator, paused
	else
		if paused
			notFrameStepping = true

mp.add_key_binding '.', 'mp_progbar_stepforward',
	->
		notFrameStepping = false
		mp.commandv 'frame_step',
	{ repeatable: true }

mp.add_key_binding ',', 'mp_progbar_stepbackward',
	->
		notFrameStepping = false
		mp.commandv 'frame_back_step',
	{ repeatable: true }

mp.observe_property 'pause', 'bool', PauseIndicatorWrapper

initDraw = ->
	mp.unregister_event initDraw
	width, height = mp.get_screen_size!
	chapters\createMarkers width, height
	playlist\updatePlaylistInfo!
	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
