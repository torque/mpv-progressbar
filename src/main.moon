local progressBar

display = OSDAggregator!

initDraw = ->
	mp.unregister_event initDraw
	unless progressBar
		width, height = mp.get_screen_size!
		progressBar = ProgressBar width, height, display
	else
		progressBar\manualDraw!

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
