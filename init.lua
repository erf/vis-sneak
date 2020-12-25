local pattern = nil
local matches = {}

local pattern_iterator = function(content, pattern)
	local offset = 1
	return function()
		local starts, ends = string.find(content, pattern, offset)
		if starts == nil then return nil end
		offset = ends + 1
		return starts, ends
	end
end

local print_matches = function(win)
	local pos = win.selection.pos
	vis:message('pos ' .. pos)
	for i, range in ipairs(matches) do
		vis:message('i ' .. i .. ' starts ' .. range.start .. ' ends ' .. range.finish)
	end
end

local highlight = function(win)

	--clear if not in matches
	local offset = win.viewport.start
	local pos = win.selection.pos
	vis:info('pos ' .. pos .. ' offset ' .. offset)
	local selection_in_match = false
	for i, range in ipairs(matches) do
		if pos >= range.start and pos <= range.finish then
			selection_in_match = true
			break
		end
	end

	-- clear matches if cursor is outside a match
	if not selection_in_match then
		matches = {}
		vis:info('clear matches')
		return
	end

	-- styles matches
	for i, range in ipairs(matches) do
		win:style(win.STYLE_CURSOR, range.start, range.finish)
	end
end

local collect_matches = function()
	local win = vis.win
	local file = win.file
	local content = file:content(0, file.size)
	matches = {}
	for starts, ends in pattern_iterator(content, pattern) do
		table.insert(matches, { start = starts - 1, finish = ends - 1 })
	end
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	highlight(win)
end)

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

vis:map(vis.modes.NORMAL, 's', function(keys)
	return sneak(keys, '/')
end)

vis:map(vis.modes.NORMAL, 'S', function(keys)
	return sneak(keys, '?')
end)
