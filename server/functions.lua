
-- ==============================
-- Whitelist Check
-- ==============================
function checkWhitelist(identifier)
    print("Whitelist check for:", identifier)
    local rowCount = MySQL.scalar.await('SELECT COUNT(1) FROM whitelisted WHERE steam = ?', { identifier })
    return rowCount and rowCount > 0
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