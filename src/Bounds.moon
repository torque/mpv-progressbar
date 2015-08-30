ffi = require 'ffi'

ffi.cdef [[
	typedef struct SI_State_priv SI_State;

	typedef struct {
		int x, y;
		unsigned int w, h;
		uint32_t hash;
		uint8_t solid;
	} SI_Rect;

	uint32_t    si_getVersion( void );
	const char* si_getErrorString( SI_State *state );
	SI_State*   si_init( int width, int height, const char* fontConfigConfig, const char *fontDir );
	void        si_changeResolution( SI_State *state, int width, int height );
	void        si_reloadFonts( SI_State *state, const char *fontConfigConfig, const char *fontDir );
	int         si_setHeader( SI_State *state, const char *header, size_t length );
	int         si_setScript( SI_State *state, const char *body, size_t length );
	int         si_calculateBounds( SI_State *state, SI_Rect *rects, const int32_t *times, const uint32_t renderCount );
	void        si_cleanup( SI_State *state );
]]

script = [[[Script Info]
ScriptType: v4.00+
WrapStyle: 0
ScaledBorderAndShadow: yes
PlayResX: 704
PlayResY: 396

[V4+ Styles]
Style: a,Source Sans Pro,50,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,3,0,2,10,10,10,1

[Events]
]]

SubInspector = ffi.load 'SubInspector'

class Bounds
	singleton = nil
	@instance = =>
		return singleton or @!

	freeInspector = ( inspector ) ->
		SubInspector.si_cleanup inspector

	new: =>
		@resX = 704
		@resY = 396
		@fontconfig = utils.join_path prefix, "fonts.conf"
		@inspector = ffi.gc SubInspector.si_init( @resX, @resY, @fontconfig, nil ), freeInspector
		if nil == @inspector
			log.warn "Bounds: SubInspector library initialization failed."
			return

		if 0 < SubInspector.si_setHeader( @inspector, script, #script )
			log.warn "Bounds: could not set script header."
			return

		singleton = @

	sizeOf: ( lines ) =>
		renderTime = ffi.new 'int32_t[1]'
		renderTime[0] = 1
		rect = ffi.new 'SI_Rect[1]'
		script = {}
		for line in *lines
			table.insert script, "Dialogue: 0,0:00:00.00,0:00:00.01,a,,0,0,0,," .. line\gsub( "\\pos%(.-%)", "" )\gsub "\\alpha&HFF&", ""

		scriptString = table.concat script, "\n"
		-- log.dump scriptString
		if 0 < SubInspector.si_setScript( @inspector, scriptString, #scriptString )
			log.warn "Could not set script" .. ffi.string( SubInspector.si_getErrorString( @inspector ) )
			return nil

		if 0 < SubInspector.si_calculateBounds @inspector, rect, renderTime, 1
			log.warn "Bounds: calculateBounds failed."
			return nil

		return {
			w: tonumber( rect[0].w )
			h: tonumber( rect[0].h )
		}
		-- log.dump a
		-- return a
