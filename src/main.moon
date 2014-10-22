local progressBar, progressBarBackground

aggregator = OSDAggregator!

initDraw = ->
	mp.unregister_event initDraw

	width, height = mp.get_screen_size!
	unless progressBar
		progressBarBackground = ProgressBarBackground aggregator
		progressBar = ProgressBar aggregator

	aggregator\setDisplaySize width, height

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
