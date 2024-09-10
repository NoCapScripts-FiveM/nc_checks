



local function checkWhitelist(identifier)
    print("Whitelist check for:", identifier)

    local rowCount = MySQL.scalar.await('SELECT COUNT(1) FROM whitelisted WHERE steam = ?', { identifier })


    return rowCount and rowCount > 0
end


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
        hexid = WBRP.Util:GetHexId(src),
        license = WBRP.Util:GetLicense(src)
    }



    print(string.format(
        "\n\27[34m[INFO]\27[0m Player Data:\n" ..
        "\27[32mName:\27[0m %s\n" ..
        "\27[32mHexID:\27[0m %s\n" ..
        "\27[32mLicense:\27[0m %s\n" ..
        "\27[33mPlayer %s is joining the server...\27[0m",
        self.name, self.hexid, self.license, self.name
    ))

    if Config.UserCheck then
        for i = 1, 3 do
            deferrals.update('Kasutajate kontroll: ' .. i .. '/3.')
            deferrals.update('Kontrollime teie andmeid: '.. self.name)
            Citizen.Wait(1000)
        end

       
        WBRP.User.CreateNewUser(self.source)
    end
   
 
    if Config.Whitelist then
        for i = 1, 5 do
            deferrals.update('Whitelisti kontroll: ' .. i .. '/5.')
            Citizen.Wait(1000)
        end

        local identifier = self.hexid
        if not identifier then
            kickPlayer(src, 'You must be connected through Steam!', setKickReason, deferrals)
            CancelEvent()
            return
        end

     
        if not checkWhitelist(identifier) then
            kickPlayer(src, 'You are not whitelisted! Please complete the whitelist process.', setKickReason, deferrals)
            CancelEvent()
            return
        end
    end

   


    exports.redux_logs:AddLog("JOIN", self.hexid, "Player joined the server", nil)


    deferrals.done()
end


AddEventHandler('playerConnecting', onPlayerConnecting)
