-- ==============================
-- Initialization
-- ==============================
Framework = ''
QBCore = nil


CreateThread(function()
    Wait(10)


    -- Check for QBCore Framework
    if GetResourceState(Config.QBCoreName) == 'starting' or GetResourceState(Config.QBCoreName) == 'started' then 
        Framework = 'QBCore'
        print("QBCore Framework initialized: ", Framework)
    end

end)

-- Player Connection Handler
CreateThread(function()
    Wait(10)
    if Framework == 'QBCore' then 
        print("Framework: " .. Framework)

      

        QBCore = exports[Config.QBCoreName]:GetCoreObject()

        function onPlayerConnecting(name, setKickReason, deferrals)
            deferrals.defer()

            local src = source
            if not src then
                deferrals.done("Error: Source not found.")
                return
            end

            local self = {
                source = src,
                name = GetPlayerName(src),
                hexid = Checks.Util:GetHexId(src),
                license = Checks.Util:GetLicense(src)
            }

            -- User Check
            if Config.UserCheck then
                for i = 1, 2 do
                    deferrals.update('Kasutaja kontroll: ' .. i .. '/2.')
                    Citizen.Wait(1000)
                end
                
                Checks.User.CreateNewUser(self.source)

                updateUserName(self.hexid, self.name)
            end

            print(string.format(
                "\n\27[34m[INFO]\27[0m Player Data:\n" ..
                "\27[32mName:\27[0m %s\n" ..
                "\27[32mHexID:\27[0m %s\n" ..
                "\27[32mLicense:\27[0m %s\n" ..
                "\27[33mPlayer %s is joining the server...\27[0m",
                self.name, self.hexid, self.license, self.name
            ))

            Wait(1000)

            -- Whitelist Check
            if Config.Whitelist then
                for i = 1, 5 do
                    deferrals.update('Whitelisti kontroll: ' .. i .. '/5.')
                    Citizen.Wait(1000)
                end

                local identifier = self.hexid
                if not identifier then
                    kickPlayer(src, 'Steami kasutaja pole ühenduses!', setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if not checkWhitelist(identifier) then
                    kickPlayer(src, 'Sinul pole whitelist tehtud! Palun tee ära, et mängida.', setKickReason, deferrals)
                    CancelEvent()
                    return
                end
            end

            Wait(1000)

            -- Name Check
            if Config.NameCheck then
                deferrals.update("📝 Nime kontroll...")
                Wait(1000)

                local PlayerName = self.name
                if not PlayerName or PlayerName == "" then 
                    QBCore.Functions.Kick(src, '❌ Tühi nimi pole lubatud.', setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if string.match(PlayerName, "[*%%'=`\"]") then
                    QBCore.Functions.Kick(src, '❌ Vigadega tähed: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
                    QBCore.Functions.Kick(src, '❌ Keelatud sõnad!', setKickReason, deferrals)
                    CancelEvent()
                    return
                end
            end

            Wait(1000)

            -- Discord Check
            if Config.Discord then
                deferrals.update("💻 Discordi kontroll...")
                Wait(1000)

                local Discord = QBCore.Functions.GetIdentifier(src, "discord")
                if not Discord or Discord:sub(1, 8) ~= "discord:" then
                    QBCore.Functions.Kick(src, '❌ Sinul peab olema discordi kasutaja!', setKickReason, deferrals)
                    CancelEvent()
                    return
                end
            end

            Wait(1000)

            -- Identifier Check
            if Config.Identifier then
                deferrals.update("💻 Litsentsi kontroll...")
                Wait(1000)

                if Config.IdentifierType == "steam" then
                    if not self.hexid or self.hexid:sub(1, 6) ~= "steam:" then
                        QBCore.Functions.Kick(src, '❌ Sinul peab olema steami kasutaja. NB! Server lubab ainult steami kasutajaid.', setKickReason, deferrals)
                        CancelEvent()
                        return
                    end
                elseif Config.IdentifierType == "license" then
                    if not self.license or self.license:sub(1, 8) ~= "license:" then
                        QBCore.Functions.Kick(src, '❌  Sinul peab olema Rockstari kasutaja. NB! Server lubab ainult Rockstari kasutajaid.', setKickReason, deferrals)
                        CancelEvent()
                        return
                    end
                end

                if Config.IdentifierType == "both" then
                    if not (self.hexid and self.hexid:sub(1, 6) == "steam:") or not (self.license and self.license:sub(1, 8) == "license:") then
                        QBCore.Functions.Kick(src, '❌ Sinul peab olema steami ja Rockstari kasutaja.', setKickReason, deferrals)
                        CancelEvent()
                        return
                    end
                end
            end

            Wait(1000)

            -- Ban Check
            if Config.Ban then
                deferrals.update("🔒 Keelustuse kontroll...")
                Wait(1000)

                local success, isBanned, reason = pcall(QBCore.Functions.IsPlayerBanned, src)
                if not success then
                    QBCore.Functions.Kick(src, 'Error fetching ban data.', setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if isBanned then
                    QBCore.Functions.Kick(src, reason, setKickReason, deferrals)
                    CancelEvent()
                    return
                end
            end

            -- Finalizing Connection
            deferrals.done()

            -- Triggering Client Events
            TriggerClientEvent('onPlayerJoining', src)
            TriggerClientEvent('NCS:Client:SharedUpdate', src, QBCore.Shared)

            -- Logging Player Join
            local user = QBCore.Functions.GetIdentifier(src, 'steam')
            
            if Config.Logs then
                exports.nc_logs:AddLog("JOIN", user, "Player joined server", nil)
            end
        end

        print("Player connection handler added")
        AddEventHandler('playerConnecting', onPlayerConnecting)
    end



    --[[ CreateThread(function()
        if not Config.SavePlayersHours then return end
    
        while true do
            local currentTime = GetGameTimer() -- Get the current game time to track the interval
            
            for _, player in pairs(_users) do
                if player.usedCharacterId and player.usedCharacterId ~= -1 then
                    if Player(player.source).state.IsInSession then
                        local character = player.GetUsedCharacter()
                        character.UpdateHours(0.5)
                    end
                end
            end
            
            -- Wait for 5 minutes before the next update
            Wait(300000) -- 5 minutes in milliseconds
        end
    end) ]]
end)
