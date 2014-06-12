local parser = {}

-- Separates out the location and the info request from the user's message.
function parser.parse_content (content)
    local loc = {}
    local req_table = {}

    content = string.gsub(content, "^%s*(.-)%s*$", "%1")    -- trim whitespace
    content = string.gsub(content, "[.,]", " ")      -- replace punctuation with spaces
    content = string.gsub(content, " (%s*)", " ")    -- remove repeated spaces
    content = content .. " "                        -- add a trailing space for splitting

    t = {}
    for f in string.gmatch(content, "(.-) ") do table.insert(t, f) end

    -- TODO: Check that the correct number of items end up in t
    if string.find(t[1], "%d") ~= nil then  -- First item in request was a zip, not city
        loc["zip"] = t[1]
        req_table["num"] = t[2]
        req_table["type"] = t[3]
        return loc, req_table
    else
        for i, v in ipairs(t) do    -- Iterate through until we get num forecasts requested.  Everything before that is the loc
            if string.find(v, "%d") ~= nil then -- Found the num forecasts requested: Right before was state, and before that the city
                loc["state"] = t[i-1]
                loc["city"] = ""
                for j=1, i-2 do loc["city"] = loc["city"] .. t[j] .. " " end
                req_table["num"] = t[i]
                req_table["type"] = t[i+1]
                return loc, req_table
            end
        end
    end
end

return parser
