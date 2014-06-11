local email = {}

-- Scans an SMTP file for the sender's email and returns it. Takes filename as arg
local function get_sender_addr (file)
	for line in file:lines() do
		for w in string.gmatch(line, "From:.- <(.-)>") do return w end
	end
end

-- Advances file position to where email content should be
local function advance_to_content (file)
	local i = 1
	for line in file:lines() do
		i = i + 1
		if string.find(line, "X%-GMAIL%-MSGID") ~= nil then break end
	end
	file:seek("cur", 1)
end

-- Reads an SMTP file and returns the actual email content
local function get_email_content (file)
	advance_to_content(file)
	local content = ""
	for line in file:lines() do
		content = content .. line
	end
	return content
end

-- Chops forecast into 160 character segments for sending over sms.
-- Returns table of chopped up strings.
local function chop_forecast (forecast)
    local i = 1
    local strs = {}
    while i < string.len(forecast) do
        table.insert(strs, string.sub(forecast, i, i+159))
        i = i + 160
    end
    return strs
end


-- Takes a filename of an SMTP file and parses out and returns the sender address and content
function email.parse_file (filename)
	local smtp_file = assert(io.open(arg[1], "r"))

	local sender_addr = get_sender_addr(smtp_file)
	local content = get_email_content(smtp_file)

	smtp_file:close()

	return sender_addr, content
end

function email.send_forecast (forecast, sender_addr)
	for _, v in ipairs(chop_forecast(forecast)) do
		os.execute("echo \"" .. v .. "\" | mail " .. sender_addr)
		os.execute("sleep 5")	-- Need to wait between messages, otherwise the first one doesn't send (?)
	end
end

return email
