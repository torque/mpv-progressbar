eventLoop = EventLoop!

notFrameStepping = false
if settings['pause-indicator']
	PauseIndicatorWrapper = ( event, paused ) ->
		if notFrameStepping
			PauseIndicator eventLoop, paused
		elseif paused
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

	notFrameStepping = true

	eventLoop\resize!
	eventLoop\redraw!
	eventLoop.updateTimer\resume!

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
