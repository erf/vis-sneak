vis:map(vis.modes.NORMAL, 's', function(keys)
	if #keys < 2 then
		return -1
	end
	vis:feedkeys('/' .. keys .. '<Enter>')
	return 2
end)

vis:map(vis.modes.NORMAL, 'S', function(keys)
	if #keys < 2 then
		return -1
	end
	vis:feedkeys('?' .. keys .. '<Enter>')
	return 2
end)
