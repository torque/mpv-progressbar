aggregator = OSDAggregator!

animationQueue = AnimationQueue aggregator

progressBar = ProgressBar animationQueue
progressBarBackground = ProgressBarBackground animationQueue
timeRemaining = TimeRemaining animationQueue

aggregator\addSubscriber progressBarBackground
aggregator\addSubscriber progressBar
aggregator\addSubscriber timeRemaining

initDraw = ->
	mp.unregister_event initDraw
	width, height = mp.get_screen_size!
	aggregator\setDisplaySize width, height

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
