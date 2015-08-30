local PreciseTimer, Timer

haveFFI, ffi = pcall require, "ffi"
if haveFFI
	haveFFI, PreciseTimer = pcall ffi.load, "PreciseTimer.dylib"

unless haveFFI
	log.warn "Could not load PreciseTimer"
	class Timer
		new: =>
			@startTime = os.time!

		currentDuration: =>
			return os.time! - @startTime

else
	ffi.cdef [[
		typedef struct CPT CPT;

		CPT* startTimer( void );
		double getDuration( CPT *pt );
		unsigned int version( void );
		void freeTimer( CPT *pt );
	]]

	class Timer
		freeTimer = ( timer ) ->
			PreciseTimer.freeTimer timer

		new: =>
			@timer = ffi.gc PreciseTimer.startTimer!, freeTimer

		currentDuration: =>
			return tonumber PreciseTimer.getDuration @timer
