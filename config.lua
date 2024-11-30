Config = Config or {}

Config.Logs = true -- Default: false [Enables logs feature with depedency resource]

-- Core Settings
Config.IdentifierType = 'steam' --[Select identifier type]
Config.ESXCoreName = 'ncfw' --[Select Framework name for ESX]
Config.QBCoreName = 'nc_fw' --[Select Framework name for QBUS]
Config.VORPCoreName = "vorp_core" --[Select Framework name for REDM VORP]

-- Gametype Feature Toggles
Config.RedM = false --[Select GameType for CFX]
Config.Fivem = true

-- Checks
Config.UserCheck = true --[User account creation and data check]
Config.SavePlayersHours = true --[User playhours ] IDK why is this here
Config.Whitelist = false --[User whitelist check ]
Config.NameCheck = true --[User name check ]
Config.Discord = false --[User discord check ]
Config.Identifier = true --[User license check ]
Config.Ban = true --[User ban check ]
