WBRP = {}

WBRP.Config = QBConfig
WBRP.Shared = QBShared
WBRP.ClientCallbacks = {}
WBRP.ServerCallbacks = {}


WBRP.Util = Util
WBRP.DB = DB
WBRP.User = User

exports('Core', function()
    return WBRP
end)