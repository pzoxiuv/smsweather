local email = {}

-- Scans an SMTP file for the sender's email and returns it. Takes filename as arg
local function get_sender_addr (file)
	for line in file:lines() do
		for w in string.gmatch(line, "Return%-Path: <(.-)>") do return w end
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

-- Takes a filename of an SMTP file and parses out and returns the sender address and content
function email.parse_file (filename)
	local smtp_file = assert(io.open(arg[1], "r"))

	local sender_addr = get_sender_addr(smtp_file)
	local content = get_email_content(smtp_file)

	smtp_file:close()

	return sender_addr, content
end

return email
