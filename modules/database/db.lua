DB = DB or {}

-- Function to check if a player exists in the database
function DB.PlayerExistsDB(self, src, callback)
    local hexId = Checks.Util:GetHexId(src)
    callback = callback or function() end

    if not hexId or hexId == "" then
        callback(false, "Invalid hexId")
        return
    end

    local query = [[SELECT hex_id FROM community_users WHERE hex_id = @id LIMIT 1;]]
    local params = {["id"] = hexId}

    exports.oxmysql:execute(query, params, function(results)
        if not results then
            callback(false, "Database query failed")
            return
        end

        local exists = #results > 0
        callback(exists)
    end)
end

-- Function to create a new user in the database
function DB.CreateNewUser(self, src, callback)
    if not src then src = source end
    local hexid = Checks.Util:GetHexId(src)
    callback = callback or function() end

    local data = {
        hexid = hexid,
        communityid = Checks.Util:HexIdToComId(hexid),
        steamid = Checks.Util:HexIdToSteamId(hexid),
        license = Checks.Util:GetLicense(src),
        name = GetPlayerName(src),
        ip = GetPlayerEndpoint(src),
        rank = "user"
    }

    -- Validate data fields
    for k, v in pairs(data) do
        if not v or v == "" then
            callback(false, "Invalid data for field: " .. k)
            return
        end
    end

    local query = [[
        INSERT INTO community_users (hex_id, steam_id, community_id, license, ip, name, rank)
        VALUES (@hexid, @steamid, @comid, @license, @ip, @name, @rank);
    ]]
    local params = {
        ["hexid"] = data.hexid,
        ["steamid"] = data.steamid,
        ["comid"] = data.communityid,
        ["license"] = data.license,
        ["ip"] = data.ip,
        ["name"] = data.name,
        ["rank"] = data.rank
    }

    exports.oxmysql:execute(query, params, function(result)
        if not result or result.affectedRows == 0 then
            callback(false, "Database insertion failed or no rows affected")
            return
        end

        callback(true)
    end)
end

-- Function to update the hours for a player in the database
function DB.UpdateHours(self, src, hours, callback)
    if not src then src = source end
    local hexid = Checks.Util:GetHexId(src)
    callback = callback or function() end

    if not hexid or hexid == "" then
        callback(false, "Invalid hexId")
        return
    end

    local query = [[
        UPDATE community_users 
        SET hours = COALESCE(hours, 0) + @hours
        WHERE hex_id = @hexid;
    ]]
    local params = {
        ["hexid"] = hexid,
        ["hours"] = hours
    }

    exports.oxmysql:execute(query, params, function(result)
        if not result or result.affectedRows == 0 then
            callback(false, "Failed to update hours or no rows affected")
            return
        end

        callback(true)
    end)
end
