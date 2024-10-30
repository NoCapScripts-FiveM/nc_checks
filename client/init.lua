WBRP = {}

Checks.Config = QBConfig
Checks.Shared = QBShared
Checks.ClientCallbacks = {}
Checks.ServerCallbacks = {}


Checks.Util = Checks.Util
Checks.DB = Checks.DB
Checks.User = Checks.User

exports('Core', function()
    return WBRP
end)