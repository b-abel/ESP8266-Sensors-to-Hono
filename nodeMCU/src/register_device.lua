
HONO_DEVICE_ID = "esp8266."..string.lower(string.gsub(wifi.sta.getmac(), "%p", ""))

http = require("http")

local registration_uri = string.format("http://%s:%i/registration/%s", HONO_HOST, HONO_HTTP_ADAPTER_PORT, HONO_TENANT)
local body = cjson.encode({ device_id = HONO_DEVICE_ID, creater = "self-registered" })
local content_type_header = 'Content-Type: application/json\r\n'

print("URI: "..registration_uri)
print("Body: "..body)

http.post(registration_uri, content_type_header, body,
    function(code, data)
        if (code == 201 or code == 409) then
            print("Registered")
            file.close("register_device.lua")
            dofile("application.lua")
        else
            print(string.format("Registration returned unknown status code %i", code))
            print("Stopped")
        end
    end)
