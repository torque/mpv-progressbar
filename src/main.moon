initDraw = ->
	mp.unregister_event initDraw
	progressBar = ProgressBar mp.get_screen_size!

mp.register_event "playback-restart", initDraw
