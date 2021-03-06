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

-- is cursor pos is in one of the matches?
local cursor_on_match = function(win)
	local pos = win.selection.pos
	for _, range in ipairs(matches) do
		if pos >= range.start and pos <= range.finish then
			return true
		end
	end
	return false
end

-- check if range is in viewport range
local range_in_viewport = function(viewport, range)
	return range.start >= viewport.start and range.finish <= viewport.finish
end

-- highlihght current matches
local highlight = function(win)

	-- clear matches if cursor is not on a match
	if not cursor_on_match(win) then
		matches = {}
		return
	end

	-- style matches in viewport
	local viewport = win.viewport
	for _, range in ipairs(matches) do
		if range_in_viewport(viewport, range) then
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
