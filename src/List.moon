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
			-- pass

	removeSortedIndices: ( elementList ) =>
		for idx = #elementList, 1, -1
			table.remove @, elementList[i]

class OrderedList extends List

	@FromDict: ( elements, orderKey ) =>
		elementList = {}
		for _, val in pairs elements
			table.insert elementList, val

		return @ orderKey, elementList

	new: ( orderKey, elements ) =>
		for idx, value in ipairs elements
			table.insert @, value

		table.sort @, ( a, b ) ->
			a[orderKey] < b[orderKey]

		@orderKey = orderKey

	insert: ( element ) =>
		for el, idx in @loop!
			if el[@orderKey] <= element[@orderKey]
				table.insert @, idx + 1, element
