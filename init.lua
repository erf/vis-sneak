local pattern = nil

vis:map(vis.modes.NORMAL, 's', function(keys)
	--vis:info('s' .. keys)
	if #keys < 2 then
		pattern = nil
		return -1
	end
	vis:feedkeys('/' .. keys .. '<Enter>')
	pattern = keys
	return 2
end)

vis:map(vis.modes.NORMAL, 'S', function(keys)
	--vis:info('s' .. keys)
	if #keys < 2 then
		pattern = nil
		return -1
	end
	vis:feedkeys('?' .. keys .. '<Enter>')
	pattern = keys
	return 2
end)

-- TODO highlight matches !
-- https://github.com/aude/vis-trailing-whitespace/blob/master/init.lua
local pattern_iterator = function(content, pattern)
	local offset = 1
	return function()
		local starts, ends = string.find(content, pattern, offset, true)
		if starts == nil then return nil end
		offset = ends + 1
		return starts, ends
	end
end

local function highlight(win)
	if pattern == nil then
		return
	end
	local content = win.file:content(win.viewport)
	local offset = win.viewport.start
	for starts, ends in pattern_iterator(content, pattern) do
		win:style(win.STYLE_CURSOR, starts - 1 + offset, ends - 1 + offset)
		if ends >= win.viewport.finish then
			break
		end
	end
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	highlight(win)
end)
