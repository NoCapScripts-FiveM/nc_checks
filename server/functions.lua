
-- ==============================
-- Whitelist Check
-- ==============================
function checkWhitelist(identifier)
    print("Whitelist check for:", identifier)
    local rowCount = MySQL.scalar.await('SELECT COUNT(1) FROM whitelisted WHERE steam = ?', { identifier })
    return rowCount and rowCount > 0
end
-- ==============================
-- Username change check
-- ==============================
function updateUserName(identifier, newName)
    -- Query to fetch the current name from the database
    local selectQuery = [[
        SELECT name FROM community_users WHERE hex_id = @hexid;
    ]]
    
    local selectParams = { ["hexid"] = identifier }

    -- Fetch the current name using oxmysql
    exports.oxmysql:execute(selectQuery, selectParams, function(result)
        if result and #result > 0 then
            local currentName = result[1].name  -- Assuming result is a table with the first row containing the name
            print("Current Name: " .. currentName)

            -- Check if the current name is different from the new name
            if currentName ~= newName then
                local updateQuery = [[
                    UPDATE community_users
                    SET name = @newname
                    WHERE hex_id = @hexid;
                ]]
                
                local updateParams = {
                    ["hexid"] = identifier,
                    ["newname"] = newName
                }
                
                -- Execute the update query
                exports.oxmysql:execute(updateQuery, updateParams, function(result)
                    if not result or result.affectedRows == 0 then
                        print("Failed to update username or no rows affected.")
                    else
                        print("User name updated successfully.")
                    end
                end)
            else
                print("No change in user name.")
            end
        else
            print("Failed to retrieve current username.")
        end
    end)
end




-- ==============================
-- Player Kick Function
-- ==============================
function kickPlayer(src, reason, setKickReason, deferrals)
    local formattedReason = "\n" .. reason

    if setKickReason then
        setKickReason(formattedReason)
    end

    Citizen.CreateThread(function()
        if deferrals then
            deferrals.update(formattedReason)
            Citizen.Wait(2500)  
        end

        if src then
            DropPlayer(src, formattedReason)
        end

        for i = 1, 4 do
            Citizen.Wait(5000) 
            if src and GetPlayerPing(src) >= 0 then
                DropPlayer(src, formattedReason)
            else
                break  
            end
        end
    end)
end