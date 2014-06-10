local weather = {}

local json = require("json")
local http = require("socket.http")

-- URL encodes string, taken from lua-users.org/wiki/StringRecipes
local function url_encode (str)
	if str then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w %-%_%.%~])",
			function (c) return string.format("%%%02X", string.byte(c)) end)
		str = string.gsub(str, " ", "+")
	end
	return str
end

-- Takes a location (city,state) and returns its latitude and longitude
local function loc_to_coord (loc)
	-- XXX: Doesn't give exact same coords as NOAA does - e.g. NOAA says coords this gives
	-- for Ambler is actually Spring House.
	body, res_code = http.request("http://api.geonames.org/postalCodeSearchJSON?placename="
									.. url_encode(loc) .. "&username=smsweather")
	if res_code ~= 200 then
		print("Error finding latitude and longitude.")
		return nil, nil
	else
		geocode_res = json.decode(body)
	end
	return geocode_res["postalCodes"][1]["lat"], geocode_res["postalCodes"][1]["lng"]
end

-- Takes a location a Lua table (converted from JSON) with forcast info
function weather.get_forcast (loc)
	lat, lon = loc_to_coord(loc)

	body, res_code = http.request("http://forecast.weather.gov/MapClick.php?lat="
									.. lat .. "&lon=" .. lon .. "&FcstType=json")
	if res_code ~= 200 then
		print("Error getting forcast.")
		return nil
	end

	return json.decode(body)
end

return weather
