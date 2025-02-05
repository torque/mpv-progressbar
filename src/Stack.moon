class Stack
	-- This goofy and weird hack works because the moonscript class implementation
	-- stores all instance methods in the metatable. The class itself is used as
	-- the stack's array-like table in order to remove yet another layer of
	-- hashtable indirection as well as to improve the syntactic sugar of using
	-- the stack by composition (allows ipairs iteration without using a
	-- metamethod).

	new: ( @containmentKey ) =>

	insert: ( element, index ) =>
		if index
			table.insert @, index, element
			element[@] = index
		else
			table.insert @, element
			element[@] = #@

		if @containmentKey
			element[@containmentKey] = true

	insertBefore: ( new, existing ) =>
		index = existing[@]
		if index
			@insert new, index
			reindex @, index + 1
		else
			@insert new

	removeElementMetadata = ( element ) =>
		element[@] = nil
		if @containmentKey
			element[@containmentKey] = false

	reindex = ( start = 1 ) =>
		for i = start, #@
			(@[i])[@] = i

	remove: ( element ) =>
		if element[@] == nil
			error "Trying to remove an element that doesn't exist in this stack."
		table.remove @, element[@]
		reindex @, element[@]
		removeElementMetadata @, element

	clear: =>
		-- not sure if allocating a new stack is slower than clearing the old one.
		-- My guess is yes, for low numbers of elements.
		-- @ = Stack!
		element = table.remove @
		while element
			removeElementMetadata @, element
			element = table.remove @

	-- This function mutates the table passed to it.
	removeSortedList: ( elementList ) =>
		if #elementList < 1
			return

		for i = 1, #elementList - 1
			element = table.remove elementList
			table.remove @, element[@]
			removeElementMetadata @, element

		lastElement = table.remove elementList
		table.remove @, lastElement[@]
		reindex @, lastElement[@]
		removeElementMetadata @, lastElement

	removeList: ( elementList ) =>
		table.sort elementList, ( a, b ) ->
			a[@] < b[@]

		@removeSortedList elementList
