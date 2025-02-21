Checks = {}

Checks.Config = QBConfig
Checks.Shared = QBShared
Checks.ClientCallbacks = {}
Checks.ServerCallbacks = {}


Checks.Util = Util
Checks.DB = DB
Checks.User = User
Checks.Core = exports[Config.ESXCoreName]:getSharedObject()



exports('Core', function()
    return Checks
end)




