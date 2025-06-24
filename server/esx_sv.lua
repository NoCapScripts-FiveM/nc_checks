-- ==============================
-- Initialization
-- ==============================
Framework = ''
Locale = Config.Lang
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
      
        ESX = exports[Config.ESXCoreName]:getSharedObject() or Checks.Core


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
            local src = source
            deferrals.defer()
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
                UserCheck(deferrals, source)
            end
            Wait(1000)

           if Config.Development then
                local identifier = self.hexid -- You need to define this to get the player's Steam hex
                IsDeveloper(deferrals, identifier, function(isDev)
                    if isDev then
                        print("Player is developer, allowing connection:", identifier, self.name)
                        -- continue connection or whatever you want here
                    else
                        print("Player is NOT developer:", identifier, self.name)
                        -- maybe reject or defer connection here using deferrals
                        if Locale == "EE" then
                            deferrals.done("Te ei ole arendaja.")
                        elseif Locale == "EN" then
                            deferrals.done("You are not a developer.")
                        end
                    end
                end)
            end


            -- EE locale
            if Locale == "EE" then

                print(string.format(
                    "\n\27[34m[INFO]\27[0m Mängija andmed:\n" ..
                    "\27[32mNimi:\27[0m %s\n" ..
                    "\27[32mHexID:\27[0m %s\n" ..
                    "\27[32mLitsents:\27[0m %s\n" ..
                    "\27[33mMängija %s liitub serverisse...\27[0m",
                    self.name, self.hexid, self.license, self.name
                ))
            end



              -- EE locale
            if Locale == "EN" then
                print(string.format(
                    "\n\27[34m[INFO]\27[0m Player Data:\n" ..
                    "\27[32mName:\27[0m %s\n" ..
                    "\27[32mHexID:\27[0m %s\n" ..
                    "\27[32mLicense:\27[0m %s\n" ..
                    "\27[33mPlayer %s is joining the server...\27[0m",
                    self.name, self.hexid, self.license, self.name
                ))
            end

            Wait(1000)

            -- Whitelist Check
            if Config.Whitelist then
                WhitelistControl(setKickReason, deferrals, self.source)
            end

            Wait(1000)

            -- Name Check
           
            if Config.NameCheck then
                NameCheck(setKickReason, deferrals, self.source)
            end
          
           

            Wait(1000)

            -- Discord Check
            if Config.Discord then
               DiscordCheck(name, setKickReason, deferrals)
            end

            Wait(1000)

            -- Identifier Check
            if Config.Identifier then
                IdentifierCheck(name, setKickReason, deferrals, self.source)
            end

            Wait(1000)

            -- Ban Check
            if Config.Ban then
                BanCheck(name, setKickReason, deferrals, self.source)
            end

            -- Finalizing Connection
            deferrals.done()

            -- Triggering Client Events
            TriggerClientEvent('onPlayerJoining', src)
          

            -- Logging Player Join
            if Config.Logs then
                exports.nc_logs:AddLog("LIITUMINE", self.name, self.license, "Player joined server", nil)
            end
        end

        print("Player connection handler added")
        AddEventHandler('playerConnecting', onPlayerConnecting)
    end



end)


RegisterCommand('addwhitelist', function(source, args, rawCommand)
    if not args[1] then
        print("Usage: /addwhitelist <license>")
        return
    end

    local license = args[1]
    addUserToWhitelist(license, function(success)
        if success then
            print("Whitelist add succeeded")
        else
            print("Whitelist add failed")
        end
    end)

end, false)

RegisterCommand('adddev', function(source, args, rawCommand)
    if not args[1] then
        print("Usage: /adddev <license>")
        return
    end

    local license = args[1]
    addUserToDev(license, function(success)
        if success then
            print("Developer add succeeded")
        else
            print("Developer add failed")
        end
    end)

end, false)
