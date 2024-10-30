User = User or {}

function User.CreateNewUser(src)

    
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
                    return
                end

                if created then
                    print("[INFO] User created successfully for source: " .. tostring(src))
                else
                    print("[ERROR] Failed to create user for source: " .. tostring(src))
                end
            end)
        else
          
            print("[INFO] User already exists for source: " .. tostring(src))
        end
    end)
end
