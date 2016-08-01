local config = require "config"
local http = require "lib.resty.http"
local find = string.find


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
  ngx.say("failed to connect CAS " .. config.pkiuri, err)
  ngx.exit(500)
  
  return
end

local body = res.body
local bp, ep = find(body, '\"code\":0')

if bp == nil and ep == nil then
    ngx.say(body)
    ngx.exit(403)
end
