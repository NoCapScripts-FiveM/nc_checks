Framework = ''
VORP = nil

CreateThread(function()
    Wait(10)


    if GetResourceState(Config.VORPCoreName) == 'starting' or GetResourceState(Config.VORPCoreName) == 'started' then 
        Framework = 'VORP'
        print("VORP Framework initialized: ", Framework)
    end
end)


-- ==============================
-- Player Connecting Logic for RedM
-- ==============================
if Framework == 'VORP' then 
    VORP = exports.vorp_core:GetCore()

    print("NC CHECKS")
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

        print(string.format(
            "\n\27[34m[INFO]\27[0m Player Data:\n" ..
            "\27[32mName:\27[0m %s\n" ..
            "\27[32mHexID:\27[0m %s\n" ..
            "\27[32mLicense:\27[0m %s\n" ..
            "\27[33mPlayer %s is joining the server...\27[0m",
            self.name, self.hexid, self.license, self.name
        ))

        -- User Check
        if Config.UserCheck then
            for i = 1, 3 do
                deferrals.update('Kasutajate kontroll: ' .. i .. '/3.')
                deferrals.update('Kontrollime teie andmeid: '.. self.name)
                Citizen.Wait(1000)
            end
            Checks.User.CreateNewUser(self.source)
        end

        if Config.Logs then
            exports.nc_logs:AddLog("JOIN", self.hexid, "Player joined the server", nil)
        end
        deferrals.done()
    end

    AddEventHandler('playerConnecting', onPlayerConnecting)
end 



