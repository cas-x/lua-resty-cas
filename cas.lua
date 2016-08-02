local config = require "config"
local http = require "lib.resty.http"
local find = string.find
local cas = ngx.shared.cas

-- only server enabled ssl will requires authenticate
if ngx.var.ssl_cipher == nil then
    return
end

if ngx.var.ssl_sesion_id ~= nil and cas ~= nil and cas:get(ngx.var.ssl_sesion_id) then
  return
end

local httpc = http.new()
local res, err = httpc:request_uri(config.pkiuri, {
  method = "POST",
  body = "cdn=" .. ngx.var.ssl_client_s_dn .. "&sdn=" .. ngx.var.ssl_client_i_dn .. "&sn=" .. ngx.var.ssl_client_serial .. "&host=" .. ngx.var.host,
  headers = {
  ["Content-Type"] = "application/x-www-form-urlencoded",
  },
  -- if you want more safety, please set true
  ssl_verify = false
  })

if not res then
  ngx.say("failed to connect CAS " .. config.pkiuri, ":", err)
  ngx.exit(500)

  return
end

local body = res.body
local bp, ep = find(body, '\"code\":0')

if bp == nil and ep == nil then
  ngx.say(body)
  ngx.exit(403)
end

if cas ~= nil then
  if ngx.var.ssl_sesion_id then
    -- cache one hour
    cas:set(ngx.var.ssl_sesion_id, true, 60*60)
  end
end
