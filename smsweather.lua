local weather = require("weather")
local email = require("email")

sender_addr, content = email.parse_file(arg[1])

forecast = weather.get_forcast(content)
print(forecast["data"]["text"][1])
