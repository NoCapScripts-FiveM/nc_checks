User = User or {}

function User.CreateNewUser(src)


    local self = {
        source = src,
        name = GetPlayerName(src),
        hexid = ESX.GetIdentifier(src, "steam"),
        license = ESX.GetIdentifier(src, "license"),
    }


    
    Citizen.Wait(1)

 
    Checks.DB:PlayerExistsDB(src, function(exists, err)
        if err then
            print("[ERROR] Failed to check if player exists: " .. err)
            return
        end

       
        if not exists then
            Checks.DB:CreateNewUser(src, function(created, err)
                if err then
                    print("[ERROR] Failed to create new user: " .. err)
                    if Config.Logs then
                        exports.nc_logs:AddLog("Kasutaja loomine", self.name, self.license, "Viga uue kasutaja loomisel!", err)
                    end
                    return
                end

                if created then
                    if Config.Logs then
                        exports.nc_logs:AddLog("Kasutaja loomine", self.name, self.license, "Kasutaja andmed on edastatud ja loodud!", nil)
                    end
                    print("[INFO] User created successfully for source: " .. tostring(src))
                else
                    if Config.Logs then
                        exports.nc_logs:AddLog("Kasutaja loomine", self.name, self.license, "Viga uue kasutaja loomisel!", src)
                    end
                    print("[ERROR] Failed to create user for source: " .. tostring(src))
                end
            end)
        else
            if Config.Logs then
                exports.nc_logs:AddLog("Kasutaja loomine", self.name, self.license, "Kasutaja on juba olemas!", src)
            end
            print("[INFO] User already exists for source: " .. tostring(src))
        end
    end)
end
