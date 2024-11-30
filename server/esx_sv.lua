-- ==============================
-- Initialization
-- ==============================
Framework = ''

ESX = nil

CreateThread(function()
    Wait(10)


    -- Check for QBCore Framework
    if GetResourceState(Config.ESXCoreName) == 'starting' or GetResourceState(Config.ESXCoreName) == 'started' then 
        Framework = 'ESX'
        print("ESX Framework initialized: ", Framework)
    end

    

end)

-- Player Connection Handler
CreateThread(function()
    Wait(10)
    if Framework == 'ESX' then 
        print("Framework: " .. Framework)

        ESX = exports[Config.ESXCoreName]:getSharedObject()


        function kickUser(source, Reason, setKickReason, deferrals)
            local src = source
            local formattedReason = "\n" .. Reason
        
            -- Set the kick reason using deferrals if provided
            if setKickReason then
                setKickReason(formattedReason)
            end
        
            Citizen.CreateThread(function()
                if deferrals then
                    deferrals.update(formattedReason)
                    Citizen.Wait(2500)  -- Allow the message to be shown before kicking
                end
        
                -- Drop the player immediately
                if src then
                    DropPlayer(src, formattedReason)
                end
        
                -- Ensure the player is dropped by checking their ping
                for i = 1, 4 do
                    Citizen.Wait(5000)  -- Wait 5 seconds before retrying
        
                    -- Check if the player is still connected
                    if src and GetPlayerPing(src) >= 0 then
                        Citizen.Wait(100)
                        DropPlayer(src, formattedReason)
                    else
                        -- If the player is already dropped, exit the loop
                        break
                    end
                end
            end)
        end




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
                hexid = ESX.GetIdentifier(src, "steam"),
                license = ESX.GetIdentifier(src, "license"),
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
                    if Config.Logs then
                        exports.nc_logs:AddLog("Whitelisti kontroll", self.name, self.license, "Kasutaja pole steami kasutajaga!", nil)
                    end
                    kickPlayer(src, 'Steami kasutaja pole ühenduses!', setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if not checkWhitelist(identifier) then
                    if Config.Logs then
                        exports.nc_logs:AddLog("Whitelisti kontroll", self.name, self.license, "Kasutaja pole whitelisti taotlus tehtud!", nil)
                    end
                    kickPlayer(src, 'Sinul pole whitelist tehtud! Palun tee ära meie whitelisti taotlus, et mängida.', setKickReason, deferrals)
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
                    kickUser(src, '❌ Vigadega tähed: ' .. string.match(PlayerName, "[*%%'=`\"]"), setKickReason, deferrals)
                    CancelEvent()
                    return
                end

                if string.match(PlayerName, "drop") or string.match(PlayerName, "table") or string.match(PlayerName, "database") then
                    if Config.Logs then
                        exports.nc_logs:AddLog("Nime kontroll", self.name, self.license, "Keelatud nimi!", nil)
                    end
                    kickUser(src, '❌ Keelatud nimi!', setKickReason, deferrals)
                    CancelEvent()
                    return
                end
            end

            Wait(1000)

            -- Discord Check
            if Config.Discord then
                deferrals.update("💻 Discordi kontroll...")
                Wait(1000)



                local Discord = NC.GetIdentifier(src, "discord")
                if not Discord or Discord:sub(1, 8) ~= "discord:" then
                    if Config.Logs then
                        exports.nc_logs:AddLog("Discordi kontroll", self.name, self.license, "Ei leitud DISCORDI litsentsi!", nil)
                    end
                    kickUser(src, '❌ Sinul peab olema discordi kasutaja!', setKickReason, deferrals)
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
                        if Config.Logs then
                            exports.nc_logs:AddLog("Litsentsi kontroll", self.name, self.license, "Ei leitud STEAMI litsentsi!", nil)
                        end
                        kickUser(src, '❌ Sinul peab olema steami kasutaja. NB! Server lubab ainult steami kasutajaid.', setKickReason, deferrals)
                        CancelEvent()
                        return
                    end
                elseif Config.IdentifierType == "license" then
                    if not self.license or self.license:sub(1, 8) ~= "license:" then
                        if Config.Logs then
                            exports.nc_logs:AddLog("Litsentsi kontroll", self.name, self.license, "Ei leitud ROCKSTARI litsentsi!", nil)
                        end
                        kickUser(src, '❌  Sinul peab olema Rockstari kasutaja. NB! Server lubab ainult Rockstari kasutajaid.', setKickReason, deferrals)
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

                local success, isBanned, reason = pcall(ESX.IsPlayerBanned, src)
                if not success then
                    kickUser(src, 'Error fetching ban data.', setKickReason, deferrals)
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
                    kickUser(src, reason, setKickReason, deferrals)
                    
                    CancelEvent()
                    return
                end
            end

            -- Finalizing Connection
            deferrals.done()

            -- Triggering Client Events
            TriggerClientEvent('onPlayerJoining', src)
          --  TriggerClientEvent('NCS:Client:SharedUpdate', src, QBCore.Shared)

            -- Logging Player Join
            if Config.Logs then
                exports.nc_logs:AddLog("LIITUMINE", self.name, self.license, "Player joined server", nil)
            end
        end

        print("Player connection handler added")
        AddEventHandler('playerConnecting', onPlayerConnecting)
    end



end)
