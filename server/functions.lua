local Locale = Config.Lang
local ESXCore = exports[Config.ESXCoreName]:getSharedObject()
-- ==============================
-- Whitelist Check
-- ==============================
function checkWhitelist(identifier)
    print("Whitelist check for:", identifier)
    local rowCount = MySQL.scalar.await('SELECT COUNT(1) FROM whitelisted WHERE steamhex = ?', { identifier })
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

-- ESX Check Functions

-- WL Check to fix
-- [    script:nc_checks] Framework: ESX
-- [    script:nc_checks] Player connection handler added
-- [      script:hardcap] Connecting: NoCap
-- [    script:nc_checks]
-- [    script:nc_checks] [INFO] Mängija andmed:
-- [    script:nc_checks] Nimi: NoCap
-- [    script:nc_checks] HexID: steam:110000141bbccb8
-- [    script:nc_checks] Litsents: license:2e53bd4d4ea8218d08ba4a04818f2b9511164a31
-- [    script:nc_checks] Mängija NoCap liitub serverisse...
-- [    script:nc_checks] Current Name: NoCap
-- [    script:nc_checks] No change in user name.
-- [    script:nc_checks] [INFO] User already exists for source: 65569
-- [      script:nc_logs] New log added to database!
-- [      script:nc_logs] Log successfully sent to Discord.
-- [    c-scripting-core] script error in native 00000000406b4b20: Argument at index 0 was null.
-- [    script:nc_checks] SCRIPT ERROR: native 00000000406b4b20: Argument at index 0 was null.
-- [    script:nc_checks] > GetPlayerName (GetPlayerName.lua:3)
-- [    script:nc_checks] > WhitelistControl (@nc_checks/server/functions.lua:118)
-- [    script:nc_checks] > handler (@nc_checks/server/esx_sv.lua:121)
function WhitelistControl(setKickReason, def)
    local pSrc = source
    local self = {
        source = pSrc,
        name = GetPlayerName(pSrc),
        hexid = ESXCore.GetIdentifier(pSrc, "steam"),
        license = ESXCore.GetIdentifier(pSrc, "license"),
    }

    
    if Locale == "ET" then
        deferrals.defer()
        for i = 1, 5 do
            deferrals.update('Whitelisti kontroll: ' .. i .. '/5.')
            Citizen.Wait(1000)
        end
    
        local identifier = self.hexid
        if not identifier then
            if Config.Logs then
                exports.nc_logs:AddLog("Steami kontroll", self.name, self.license, "Kasutaja pole steami kasutajaga!", nil)
            end
            kickPlayer(src, 'Steami kasutaja pole ühenduses!', setKickReason, deferrals)
            CancelEvent()
            return
        end
    
        if not checkWhitelist(identifier) then
            if Config.Logs then
                exports.nc_logs:AddLog("Whitelisti kontroll", self.name, self.license, "Kasutaja pole whitelisti taotlus tehtud!", nil)
            end
            kickPlayer(src, 'Sinul pole whitelist tehtud! Palun tee ära meie whitelisti taotlus, et mängida. UCP:'..Config.UCPWebsite, setKickReason, deferrals)
            CancelEvent()
            return
        end
    

    end

    if Locale == "EN" then 
        deferrals.defer()
        for i = 1, 5 do
            deferrals.update('Whitelist check: ' .. i .. '/5.')
            Citizen.Wait(1000)
        end
    
        local identifier = self.hexid
        if not identifier then
            if Config.Logs then
                exports.nc_logs:AddLog("Steam Check", self.name, self.license, "Your account is not using steam!", nil)
            end
            kickPlayer(src, 'Didnt found steam account data!', setKickReason, deferrals)
            CancelEvent()
            return
        end
    
        if not checkWhitelist(identifier) then
            if Config.Logs then
                exports.nc_logs:AddLog("Whitelist Check", self.name, self.license, "User hasnt completed his whitelist test!", nil)
            end
            kickPlayer(src, 'You dont have whitelisted access! Complete it in:'..Config.UCPWebsite, setKickReason, deferrals)
            CancelEvent()
            return
        end

    end
   
end

exports('WhitelistControl', function(name, setKickReason, def)
    def.defer()
    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    local src = source
    if Locale == "ET" then

        for i = 1, 5 do
            def.update('Whitelisti kontroll: ' .. i .. '/5.')
            Citizen.Wait(1000)
        end
    
        local identifier = self.hexid
        if not identifier then
            if Config.Logs then
                exports.nc_logs:AddLog("Steami kontroll", self.name, self.license, "Kasutaja pole steami kasutajaga!", nil)
            end
            kickPlayer(src, 'Steami kasutaja pole ühenduses!', setKickReason, def)
            CancelEvent()
            return
        end
    
        if not checkWhitelist(identifier) then
            if Config.Logs then
                exports.nc_logs:AddLog("Whitelisti kontroll", self.name, self.license, "Kasutaja pole whitelisti taotlus tehtud!", nil)
            end
            kickPlayer(src, 'Sinul pole whitelist tehtud! Palun tee ära meie whitelisti taotlus, et mängida. UCP:'..Config.UCPWebsite, setKickReason, def)
            CancelEvent()
            return
        end
    

    end

    if Locale == "EN" then 

        for i = 1, 5 do
            def.update('Whitelist check: ' .. i .. '/5.')
            Citizen.Wait(1000)
        end
    
        local identifier = self.hexid
        if not identifier then
            if Config.Logs then
                exports.nc_logs:AddLog("Steam Check", self.name, self.license, "Your account is not using steam!", nil)
            end
            kickPlayer(src, 'Didnt found steam account data!', setKickReason, def)
            CancelEvent()
            return
        end
    
        if not checkWhitelist(identifier) then
            if Config.Logs then
                exports.nc_logs:AddLog("Whitelist Check", self.name, self.license, "User hasnt completed his whitelist test!", nil)
            end
            kickPlayer(src, 'You dont have whitelisted access! Complete it in:'..Config.UCPWebsite, setKickReason, def)
            CancelEvent()
            return
        end

    end

end)

function NameCheck(setKickReason, def)
    print("NameCheck")
    local src = source
    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    def.defer()
    if Locale == "EE" then
       
        def.update("📝 Nime kontroll...")
        Wait(1000)

        local PlayerName = self.name
        if not PlayerName or PlayerName == "" then
            if Config.Logs then
                exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Tühi nimi pole lubatud!", nil)
            end
            kickUser(src, '❌ Tühi nimi pole lubatud.', setKickReason, deferrals)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "[*%%'=`\"]") then
            if Config.Logs then
                exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Vigadega tähed!", nil)
            end
            kickUser(src, '❌ Vigadega tähed: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, def)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
            if Config.Logs then
                exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Keelatud nimi!", nil)
            end
            kickUser(src, '❌ Keelatud nimi!', setKickReason, def)
            CancelEvent()
            return
        end
       
    end

    if Config.Lang == "EN" then 

       
        def.update("📝 Name check...")
        Wait(1000)

        local PlayerName = self.name
        if not PlayerName or PlayerName == "" then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "Empty name was given!", nil)
            end
            kickUser(src, '❌ Empty name not allowed. Change your name or rename.', setKickReason, def)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "[*%%'=`\"]") then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "His name had bad characters!", nil)
            end
            kickUser(src, '❌ Bad characters in name: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, def)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "Name not allowed!", nil)
            end
            kickUser(src, '❌ Name not allowed!', setKickReason, def)
            CancelEvent()
            return
        end
        

    end

end


exports('NameCheck', function(name, setKickReason, def)

    local src = source
    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    def.defer()

    if Config.Lang == "EE" then
       
            def.update("📝 Nime kontroll...")
            Wait(1000)

            local PlayerName = self.name
            if not PlayerName or PlayerName == "" then
                if Config.Logs then
                    exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Tühi nimi pole lubatud!", nil)
                end
                kickUser(src, '❌ Tühi nimi pole lubatud.', setKickReason, def)
                CancelEvent()
                return
            end

            if string.match(PlayerName, "[*%%'=`\"]") then
                if Config.Logs then
                    exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Vigadega tähed!", nil)
                end
                kickUser(src, '❌ Vigadega tähed: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, def)
                CancelEvent()
                return
            end

            if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
                if Config.Logs then
                    exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Keelatud nimi!", nil)
                end
                kickUser(src, '❌ Keelatud nimi!', setKickReason, def)
                CancelEvent()
                return
            end
       
    end

    if Config.Lang == "EN" then 

        
        def.update("📝 Name check...")
        Wait(1000)

        local PlayerName = self.name
        if not PlayerName or PlayerName == "" then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "Empty name was given!", nil)
            end
            kickUser(src, '❌ Empty name not allowed. Change your name or rename.', setKickReason, def)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "[*%%'=`\"]") then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "His name had bad characters!", nil)
            end
            kickUser(src, '❌ Bad characters in name: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, def)
            CancelEvent()
            return
        end

        if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
            if Config.Logs then
                exports.nc_logs:AddLog("Name Check", self.name, self.license, "Name not allowed!", nil)
            end
            kickUser(src, '❌ Name not allowed!', setKickReason, def)
            CancelEvent()
            return
        end
    

    end

end)


function DiscordCheck(name, setKickReason, def)
    local src = source
    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    def.defer()
    if Locale == "ET" then
        def.update("💻 Discordi kontroll...")
        Wait(1000)



        local Discord = NC.GetIdentifier(src, "discord")
        if not Discord or Discord:sub(1, 8) ~= "discord:" then
            if Config.Logs then
                exports.nc_logs:AddLog("Discordi kontroll", self.name, self.license, "Ei leitud DISCORDI litsentsi!", nil)
            end
            kickUser(src, '❌ Sinul peab olema discordi kasutaja!', setKickReason, def)
            CancelEvent()
            return
        end
    end

    if Locale == "EN" then

        def.update("💻 Discord Check...")
        Wait(1000)



        local Discord = NC.GetIdentifier(src, "discord")
        if not Discord or Discord:sub(1, 8) ~= "discord:" then
            if Config.Logs then
                exports.nc_logs:AddLog("Discord Check", self.name, self.license, "Didnt found any discord license!", nil)
            end
            kickUser(src, '❌ This server allows discord users only!', setKickReason, def)
            CancelEvent()
            return
        end
    end


end

function IdentifierCheck(name, setKickReason, deferrals)
    local src = source
    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    def.defer()

    if Locale == "ET" then
        def.update("💻 License Check...")
        Wait(1000)

        if Config.IdentifierType == "steam" then
            if not self.hexid or self.hexid:sub(1, 6) ~= "steam:" then
                if Config.Logs then
                    exports.nc_logs:AddLog("License Check", self.name, self.license, "Ei leitud STEAMI litsentsi!", nil)
                end
                kickUser(src, '❌ Sinul peab olema steami kasutaja. NB! Server lubab ainult steami kasutajaid.', setKickReason, deferrals)
                CancelEvent()
                return
            end
        elseif Config.IdentifierType == "license" then
            if not self.license or self.license:sub(1, 8) ~= "license:" then
                if Config.Logs then
                    exports.nc_logs:AddLog("License Check", self.name, self.license, "Ei leitud ROCKSTARI litsentsi!", nil)
                end
                kickUser(src, '❌  Sinul peab olema Rockstari kasutaja. NB! Server lubab ainult Rockstari kasutajaid.', setKickReason, deferrals)
                CancelEvent()
                return
            end
        end
    end

    if Locale == "EN" then 

        def.update("💻 License Check...")
        Wait(1000)

        if Config.IdentifierType == "steam" then
            if not self.hexid or self.hexid:sub(1, 6) ~= "steam:" then
                if Config.Logs then
                    exports.nc_logs:AddLog("License Check", self.name, self.license, "Didnt found the correct license!", nil)
                end
                kickUser(src, '❌  This server accepts only [Steam] users.', setKickReason, def)
                CancelEvent()
                return
            end
        elseif Config.IdentifierType == "license" then
            if not self.license or self.license:sub(1, 8) ~= "license:" then
                if Config.Logs then
                    exports.nc_logs:AddLog("License Check", self.name, self.license, "Didnt found Rockstar license!", nil)
                end
                kickUser(src, '❌  This server accepts only [Rockstar] users.', setKickReason, def)
                CancelEvent()
                return
            end
        end
    end

end


function BanCheck(name, setKickReason, def)
    local src = source
    self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    def.defer()
    
    if Config.Lang == "ET" then
        def.update("🔒 Keelustuse kontroll...")
        Wait(1000)

        local success, isBanned, reason = pcall(ESXCore.IsPlayerBanned, src)
        if not success then
            kickUser(src, 'Error fetching ban data.', setKickReason, def)
            if Config.Logs then
                exports.nc_logs:AddLog("Keelustuse kontroll", self.name, self.license, "Viga andmete saamisel", nil)
            end
            CancelEvent()
            return
        end

        if isBanned then
            if Config.Logs then
                exports.nc_logs:AddLog("Keelustuse kontroll", self.name, self.license, "See isik on meie serverist keelustatud!", nil)
            end
            kickUser(src, reason, setKickReason, def)
            
            CancelEvent()
            return
        end
    end


    if Locale == "EN" then 
        def.update("🔒 Ban type check...")
        Wait(1000)

        local success, isBanned, reason = pcall(ESXCore.IsPlayerBanned, src)
        if not success then
            kickUser(src, 'Error fetching ban data.', setKickReason, def)
            if Config.Logs then
                exports.nc_logs:AddLog("Ban check", self.name, self.license, "Error fetching ban data.", nil)
            end
            CancelEvent()
            return
        end

        if isBanned then
            if Config.Logs then
                exports.nc_logs:AddLog("Ban Check", self.name, self.license, "This user is banned from our server!", nil)
            end
            kickUser(src, reason, setKickReason, def)
            
            CancelEvent()
            return
        end
    end
        

end


function UserCheck(def, pSrc)
    def.defer()
    local src = source
    self = {
        source = src,
        name = GetPlayerName(pSrc),
        hexid = ESXCore.GetIdentifier(src, "steam"),
        license = ESXCore.GetIdentifier(src, "license"),
    }
    
   
    if Locale == "EE" then
        for i = 1, 2 do
            def.update('Kasutaja kontroll: ' .. i .. '/2.')
            Citizen.Wait(1000)
        end
        
        Checks.User.CreateNewUser(self.source)

        updateUserName(self.hexid, self.name)
    end

    if Locale == "EN" then 

        for i = 1, 2 do
            def.update('User account check: ' .. i .. '/2.')
            Citizen.Wait(1000)
        end
        
        Checks.User.CreateNewUser(self.source)

        updateUserName(self.hexid, self.name)
    end

end

