local weather = {}

local json = require("json")
local http = require("socket.http")

-- URL encodes string, taken from lua-users.org/wiki/StringRecipes
local function url_encode (str)
	if str then
		str = string.gsub(str, " ", "+")
	end
	return str
end

-- Takes a location (city & state or zip) and returns its latitude and longitude
local function loc_to_coord (loc)
	local loc_str = ""
	if string.find(loc, "%d") ~= nil then
		loc_str = "&zip=" .. loc
	else
		local city_state = {}
		loc = loc .. "," -- Make sure loc ends in comma so pattern match below works. XXX better way to do this?
		for field in string.gmatch(loc, "(.-),") do table.insert(city_state, field) end
		loc_str = "&city=" .. city_state[1] .. "&state=" .. city_state[2]
	end

	local body, res_code = http.request("http://geoservices.tamu.edu/services/geocode/webservice/geocoderwebservicehttpnonparsed_v04_01.aspx?apikey=953e7c59b87544f7bcf9a7068ef18d30&version=4.01" .. url_encode(loc_str))

	if res_code ~= 200 then
		print("Error finding latitude and longitude.")
		return nil, nil
	end

	results_table = {}
	for field in string.gmatch(body, "(.-),") do table.insert(results_table, field) end
	return results_table[4], results_table[5]
end

-- Takes a location a Lua table (converted from JSON) with forecast info
function weather.get_forecast (loc)
	lat, lon = loc_to_coord(loc)

	body, res_code = http.request("http://forecast.weather.gov/MapClick.php?lat="
									.. lat .. "&lon=" .. lon .. "&FcstType=json")
	if res_code ~= 200 then
		print("Error getting forecast.")
		return nil
	end

	return json.decode(body)
end

return weather
