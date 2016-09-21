local _M = {}
_M._version = '0.1.0'

local config = require "config"
local http = require "lib.resty.http"
local find = string.find
local cas = ngx.shared.cas
local string_format = string.format
local string_sub = string.sub
local ngx_find = ngx.re.find

function _M.run(enable_host)
    local id = id or ngx.var.ssl_client_serial
    local enable = 0

    if enable_host == true then
        enabled = 1
    else
        enabled = 0
    end

    -- only server enabled ssl will requires authenticate
    if ngx.var.ssl_cipher == nil then
        return
    end

    if id ~= nil and cas ~= nil then
        local value, flags = cas:get(id)
        if value then
            ngx.req.set_header("Authorization", "Bearer " .. value)

            return
        end
    end

    local httpc = http.new()
    local res, err = httpc:request_uri(config.pkiuri, {
      method = "POST",
      body = string_format('inhost=%d&cdn=%s&sdn=%s&sn=%s&host=%s', enabled,
        ngx.var.ssl_client_s_dn, ngx.var.ssl_client_i_dn, ngx.var.ssl_client_serial, ngx.var.host),
      headers = {
      ["Content-Type"] = "application/x-www-form-urlencoded",
      },
      -- if you want more safety, please set true
      ssl_verify = false
      })

    if not res then
        ngx.header.content_type = 'text/html';
        ngx.say("failed to connect CAS " .. config.pkiuri, ":", err)
        ngx.exit(500)

      return
    end

    local body = res.body
    local bp, ep = find(body, '\"code\":0')

    if bp == nil and ep == nil then
        ngx.header.content_type = 'application/json';
        ngx.say(body)
        ngx.exit(403)

        return
    end

    -- Bearer XXXXXXXX
    local from, to, err = ngx_find(body, '\"value\":\s*\"(.*)\"', "jo", nil, 1)

    if from then
        local token = string_sub(body, from, to)
        ngx.req.set_header("Authorization", "Bearer " .. token)

        if cas ~= nil then
            if id then
                -- cache 15 minute
                local succ, err, forcible = cas:set(id, token, config.jwt.expire)

                -- can ignore succ
                -- if success we will cache the JWT else will reauthenticated to CAS everty request
            end
        end

        return
    end

    ngx.header.content_type = 'text/html';
    ngx.say('<h1>CAS JWT ERROR</h1>')
    ngx.say(body)

    return ngx.exit(500)
end

return _M
