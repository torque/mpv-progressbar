aggregator = OSDAggregator!

animationQueue = AnimationQueue aggregator

progressBar = ProgressBar animationQueue
progressBarBackground = ProgressBarBackground animationQueue
timeElapsed = TimeElapsed animationQueue
timeRemaining = TimeRemaining animationQueue
hoverTime = HoverTime animationQueue

aggregator\addSubscriber progressBarBackground
aggregator\addSubscriber progressBar
aggregator\addSubscriber timeElapsed
aggregator\addSubscriber timeRemaining
aggregator\addSubscriber hoverTime

initDraw = ->
	mp.unregister_event initDraw
	width, height = mp.get_screen_size!
	aggregator\setDisplaySize width, height

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
