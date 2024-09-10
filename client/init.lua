WBRP = {}

WBRP.Config = QBConfig
WBRP.Shared = QBShared
WBRP.ClientCallbacks = {}
WBRP.ServerCallbacks = {}


WBRP.Util = WBRP.Util
WBRP.DB = WBRP.DB
WBRP.User = WBRP.User

exports('Core', function()
    return WBRP
end)