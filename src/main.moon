local progressBar

initDraw = ->
	log.info "Firing initDraw."
	mp.unregister_event initDraw
	unless progressBar
		progressBar = ProgressBar mp.get_screen_size!
	else
		progressBar\manualDraw!

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
