local parser = {}

-- Parses out the city & state or zip code of the given location string.
function parser.parse_loc (loc)
	local city = nil
	local state = nil
	local zip = nil
    if string.find(loc, "%d") ~= nil then
		zip = loc
    else
        local city_state = {}
        loc = loc .. "," -- Make sure loc ends in comma so pattern match below works. XXX better way to do this?
        for field in string.gmatch(loc, "(.-),") do table.insert(city_state, field) end
		city = city_state[1]
		state = city_state[2]
    end
	return city, state, zip
end

return parser
