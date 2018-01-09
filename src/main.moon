commandIcon = CommandIcon!
predefinedElements = OrderedList 'layer', {
	Chapters!
	ProgressBar!
	ProgressBarCache!
	ProgressBarBackground!

	TimeElapsed!
	TimeRemaining!
	HoverTime!

	Title!
	SystemTime!

	commandIcon
}


activeHeight = settings['hover-zone-height']
zone = ElementGroup predefinedElements, {Mouse.LeftClick, Mouse.RightClick, Mouse.Scroll, Mouse.Hover}, =>
	@reset 0, Window.h - activeHeight, Window.w, activeHeight

compositor = Compositor predefinedElements, List {zone}
eventLoop = EventLoop compositor
Window\registerResizable compositor

mp.observe_property 'pause', 'bool', ( ev, paused ) ->
	commandIcon\showIcon paused and 'pause' or 'play'

initDraw = ->
	mp.unregister_event initDraw

	mp.command 'script-message-to osc disable-osc'
	eventLoop\start!

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
