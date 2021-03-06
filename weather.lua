local weather = {}

local json = require("json")
local http = require("socket.http")
local parser = require("parser")

-- URL encodes string, taken from lua-users.org/wiki/StringRecipes
local function url_encode (str)
	if str then
		str = string.gsub(str, " ", "+")
	end
	return str
end

-- Takes a location (city & state or zip) and returns its latitude and longitude
local function loc_to_coord (loc)
	if loc["city"] ~= nil and loc["state"] ~= nil then loc_str = "city=" .. loc["city"] .. "&state=" .. loc["state"]
	elseif loc["zip"] ~= nil then loc_str = "zip=" .. loc["zip"]
	else return nil, nil end	-- No valid loc

	local body, res_code = http.request("http://geoservices.tamu.edu/services/geocode/webservice/geocoderwebservicehttpnonparsed_v04_01.aspx?apikey=953e7c59b87544f7bcf9a7068ef18d30&version=4.01&" .. url_encode(loc_str))

	if res_code ~= 200 then
		return nil, nil
	end

	results_table = {}
	for field in string.gmatch(body, "(.-),") do table.insert(results_table, field) end

	if results_table[3] ~= "200" then
		return nil, nil
	end

	return results_table[4], results_table[5]
end

-- Takes a location a Lua table (converted from JSON) with forecast info
function weather.get_forecast (loc)
	lat, lon = loc_to_coord(loc)

	if lat == nil or lon == nil then
		print("Error converting location into latitude and longitude.")
		return nil
	end

	body, res_code = http.request("http://forecast.weather.gov/MapClick.php?lat="
									.. lat .. "&lon=" .. lon .. "&FcstType=json")
	if res_code ~= 200 then
		print("Error retrieving forecast from NOAA.")
		return nil
	end

	return json.decode(body)
end

local function reduce_forecast (forecast)
	local orig_forecast = forecast
	local reduced_forecast = ""

	-- Remove wind speed and precipitation sentences.
	for f in string.gmatch(forecast, "(.-)%.") do
		if string.find(f, "amount") == nil and string.find(f, "mph") == nil then
			reduced_forecast = reduced_forecast .. f .. "."
		end
	end

	-- Remove repeated spaces
	reduced_forecast = string.gsub(reduced_forecast, " (%s*)", " ")

	if math.ceil(string.len(reduced_forecast)/160) < math.ceil(string.len(orig_forecast)/160) then
		return reduced_forecast
	else
		return orig_forecast
	end
end

-- Takes in the user's info request and a forecast table and returns a string with the requested info.
function weather.prepare_forecast (forecast, req)
	local forecast_str = ""

	if req["type"] == "full" then
		for i=1, req["num"] do
			forecast_str = forecast_str .. forecast["time"]["startPeriodName"][i] .. ": " .. forecast["data"]["text"][i]
		end
	elseif req["type"] == "short" or req["type"] == "long" then
		for i=1, req["num"] do
			forecast_str = forecast_str .. forecast["time"]["startPeriodName"][i] .. ": " .. forecast["data"]["weather"][i] .. ". "
		end
        forecast_str = string.gsub(forecast_str, "^%s*(.-)%s*$", "%1")
		if req["type"] == "long" then forecast_str = reduce_forecast(forecast_str) end
	else
		return nil
	end

	return forecast_str
end

return weather
