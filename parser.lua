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

-- Separates out the location and the info request from the user's message.
function parser.parse_content (content)
	if string.find(content, "%.") == nil then return content end
	return string.sub(content, string.find(content, "%.")-1),
		   string.sub(content, string.find(content, "%.")+1)
end

-- Parses out the info the user is requesting.  See README for valid info and formatting.
function parser.parse_req (req)
	req_table = {}
	if req == nil then
		req_table["forecast"] = true
		req_table["num_forecasts"] = 1
		return req_table
	end

	req = req .. ","
	for info in string.gmatch(req, "(.-),") do table.insert(req_table, info) end
end

return parser
