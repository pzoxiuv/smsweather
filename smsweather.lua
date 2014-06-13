-- XXX: This seems hacky?
package.path = package.path .. ';/home/alex/Programming/smsweather/?.lua'
local weather = require("weather")
local email = require("email")
local parser = require("parser")

local function err ()
	--email.send_forecast("Sorry, there was an error!", sender_addr)
	os.exit()
end

local sender_addr, content = email.parse_file(arg[1])
if sender_addr == nil or content == nil then
	print("Error, sender_addr or content nil")
	os.exit()
end

local loc, req  = parser.parse_content(content)
if loc == nil or req == nil then
	err()
end

local forecast = weather.get_forecast(loc)
if forecast == nil then
	err()
end

local forecast_str = weather.prepare_forecast(forecast, req)
if forecast_str == nil then
	err()
end

print(forecast_str)

--email.send_forecast(forecast_str, sender_addr)
