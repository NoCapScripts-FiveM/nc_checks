DB = DB or {}

-- Function to check if a player exists in the database
function DB.PlayerExistsDB(self, src, callback)
    local hexId = Checks.Util:GetHexId(src)
    callback = callback or function() end

    if not hexId or hexId == "" then
        callback(false, "Invalid hexId")
        return
    end

    Mongo:FindOne({
        collection = "community_users",
        query = { hex_id = hexId }
    }, function(result)
        if result then
            callback(true)  -- Player found
        else
            callback(false) -- Player not found
        end
    end)
end

-- Function to create a new user in the database
function DB.CreateNewUser(self, src, callback)
    if not src then src = source end
    local hexid = Checks.Util:GetHexId(src)
    callback = callback or function() end

    local data = {
        hex_id = hexid,
        community_id = Checks.Util:HexIdToComId(hexid),
        steam_id = Checks.Util:HexIdToSteamId(hexid),
        license = Checks.Util:GetLicense(src, "license"),
        discord = Checks.Util:GetLicense(src, "discord"),
        name = GetPlayerName(src),
        ip = GetPlayerEndpoint(src),
        rank = "user",
        hours = 0
    }

    -- Validate data fields
    for k, v in pairs(data) do
        if not v or v == "" then
            callback(false, "Invalid data for field: " .. k)
            return
        end
    end

    Mongo:InsertOne({
        collection = "community_users",
        document = data
    }, function(result)
        if result then
            callback(true)
        else
            callback(false, "Database insertion failed")
        end
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

    Mongo:UpdateOne({
        collection = "community_users",
        query = { hex_id = hexid },
        update = { ["$inc"] = { hours = hours } }
    }, function(result)
        if result and result.modifiedCount and result.modifiedCount > 0 then
            callback(true)
        else
            callback(false, "Failed to update hours")
        end
    end)
end
