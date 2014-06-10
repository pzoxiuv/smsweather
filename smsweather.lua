local weather = require("weather")
local email = require("email")

sender_addr, content = email.parse_file(arg[1])

print(sender_addr)
print(content)

forcast = weather.get_forcast(content)
print(forcast["data"]["text"][1])
