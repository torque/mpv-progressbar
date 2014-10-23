aggregator = OSDAggregator!
animationQueue = AnimationQueue aggregator
progressBarBackground = ProgressBarBackground aggregator, animationQueue
progressBar = ProgressBar aggregator, animationQueue

initDraw = ->
	mp.unregister_event initDraw
	width, height = mp.get_screen_size!
	aggregator\setDisplaySize width, height

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
