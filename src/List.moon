class List
	-- This goofy and weird hack works because the moonscript class implementation
	-- stores all instance methods in the metatable. The class itself is used as
	-- the stack's array-like table in order to remove yet another layer of
	-- hashtable indirection as well as to improve the syntactic sugar of using
	-- the stack by composition (allows ipairs iteration without using a
	-- metamethod).

	@FromDict: ( elements, sortKey ) =>
		result = {}
		for key, val in pairs elements
			table.insert result, val

		if sortKey != nil
			table.sort result, ( a, b ) =>
				return a[sortKey] < b[sortKey]

		return @ result

	new: ( elements ) =>
		if elements
			for idx, element in ipairs elements
				@[idx] = element

	insert: ( element, index ) =>
		if index
			if index < 0
				index = #@ - index + 2
			table.insert @, index, element
		else
			table.insert @, element

	shift: =>
		return table.remove @, 1

	pop: ( idx ) =>
		return table.remove @, idx

	contains: ( element ) =>
		for idx, el in ipairs @
			if el == element
				-- 0 is not falsy in lua and arrays are 1-indexed regardless, so this
				-- should be safe.
				return idx

		return false

	loop: =>
		idx = #@ + 1
		return ->
			idx -= 1
			return @[idx], idx

	remove: ( element ) =>
		indexList = {}
		for idx, el in ipairs @
			if el == element
				table.insert indexList, idx

		switch #indexList
			when 0
				error 'element not in list'
			when 1
				table.remove @, indexList[1]
			else
				@removeSortedIndices indexList

		return indexList

	clear: =>
		while table.remove @
			-- no empty loops allowed?
			0

	removeSortedIndices: ( elementList ) =>
		for idx = #elementList, 1, -1
			table.remove @, elementList[i]

class OrderedList extends List

	@FromDict: ( elements, orderKey ) =>
		elementList = {}
		if elements
			for _, element in pairs elements
				table.insert elementList, element

		return @ orderKey, elementList

	new: ( orderKey, elements ) =>
		if elements
			for idx, value in ipairs elements
				table.insert @, value

			table.sort @, ( a, b ) ->
				a[orderKey] < b[orderKey]

		-- I don't think this should pose a problem because Lua distinguishes the
		-- hash space from the list space in a table.
		@orderKey = orderKey

	insert: ( element ) =>
		if element[@orderKey] == nil
			error "Element doesn't have member #{@orderKey}"

		for el, idx in @loop!
			if el[@orderKey] <= element[@orderKey]
				table.insert @, idx + 1, element
				return

		table.insert @, 1, element
