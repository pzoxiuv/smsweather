-- XXX: This seems hacky?
package.path = package.path .. ';/home/alex/Programming/smsweather/?.lua'
local weather = require("weather")
local email = require("email")
local parser = require("parser")

sender_addr, content = email.parse_file(arg[1])
loc, req  = parser.parse_content(content)

local forecast = weather.get_forecast(loc)
local forecast_str = weather.prepare_forecast(forecast, req)

email.send_forecast(forecast_str, sender_addr)
