local weather = require("weather")
local email = require("email")

sender_addr, content = email.parse_file(arg[1])

local forecast = weather.get_forecast(content)
local forecast_str = forecast["data"]["text"][1]

email.send_forecast(forecast_str, sender_addr)
