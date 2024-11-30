
Util = Util or {}


function Util.HexIdToSteamId(self, hexid)
    local cid = self:HexIdToComId(hexid)
    local steam64 = math.floor(tonumber(string.sub(cid, 2)))
    local a = steam64 % 2 == 0 and 0 or 1
    local b = math.floor(math.abs(6561197960265728 - steam64 - a) / 2)
    local sid = "STEAM_0:" .. a .. ":" .. (a == 1 and b - 1 or b)
    return sid
end


function Util.HexIdToComId(self, hexid)
    return math.floor(tonumber(string.sub(hexid, 7), 16))
end


function Util.GetHexId(self, src)

    local id = GetPlayerIdentifierByType(src, 'steam')


    if id then 
        return id 

    end

    return false
end

function Util.GetDiscord(self, src)
    local discordPrefix = "discord:"
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, #discordPrefix) == discordPrefix then
            return identifier
        end
    end
    return false
end



function Util.GetLicense(self, src, type)
    local sid = tonumber(src)
    local licenses = {}

    licenses = GetPlayerIdentifiers(sid)

    
    for k,v in ipairs(licenses) do
        if string.sub(v, 1, 7) == type then
            return v
        end
       
    end
   -- return false
end


function Util.GetIdType(self, src, type)
    local len = string.len(type)
    local sid = tonumber(src)
    for _, v in ipairs(GetPlayerIdentifiers(sid)) do
        if string.sub(v, 1, len) == type then
            return v
        end
    end
    return false
end


function Util.Stringsplit(self, inputstr, sep)
    sep = sep or "%s"
    local t = {}
    local i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end


function Util.IsSteamId(self, id)
    id = tostring(id)
    return id and string.match(id, "^STEAM_[01]:[01]:%d+$") ~= nil
end


function Util.CommaValue(self, n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end