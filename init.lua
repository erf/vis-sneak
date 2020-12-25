local pattern = nil
local matches = {}

-- iterater for doing find in pattern until nil
local pattern_iterator = function(content, pattern)
	local offset = 1
	return function()
		local starts, ends = string.find(content, pattern, offset)
		if starts == nil then return nil end
		offset = ends + 1
		return starts, ends
	end
end

-- highlihght current matches
local highlight = function(win)

	--clear if pos is not in one of the matches
	local pos = win.selection.pos
	local in_match = false
	for i, range in ipairs(matches) do
		if pos >= range.start and pos <= range.finish then
			in_match = true
			break
		end
	end

	-- clear matches if cursor is outside a match
	if not in_match then
		matches = {}
		return
	end

	-- style matches in viewport
	local viewport = win.viewport
	for i, range in ipairs(matches) do
		if range.start >= viewport.start and range.finish <= viewport.finish then
			win:style(win.STYLE_CURSOR, range.start, range.finish)
		end
	end
end

-- collect matches (ranges) for pattern in file
local collect_matches = function()
	local file = vis.win.file
	local content = file:content(0, file.size)
	matches = {}
	for starts, ends in pattern_iterator(content, pattern) do
		table.insert(matches, { start = starts - 1, finish = ends - 1 })
	end
end

-- highlight matches on WIN_HIGHLIGHT
vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	highlight(win)
end)

-- create search for two chars and collect matches for highlighting
local sneak = function(keys, search_char)
	if #keys < 2 then
		pattern = nil
		return -1
	end
	vis:feedkeys(search_char .. keys .. '<Enter>')
	pattern = keys
	collect_matches()
	return 2
end

-- sneak forward on 's'
vis:map(vis.modes.NORMAL, 's', function(keys)
	return sneak(keys, '/')
end)

-- sneak backwards on 'S'
vis:map(vis.modes.NORMAL, 'S', function(keys)
	return sneak(keys, '?')
end)
