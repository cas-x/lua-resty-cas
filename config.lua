local os = require("os")
local casurl = os.getenv('CAS-URL')

local _M = {
    pkiuri = casurl .. '/public/pkis/crt',
    jwt = {
        expire = 10 * 60
    }
}

return _M
