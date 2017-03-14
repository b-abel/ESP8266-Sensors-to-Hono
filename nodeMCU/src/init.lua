-- load config and credentials
dofile("config.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Starting application")
        file.close("init.lua")
        dofile("application.lua")
    end
end

print("Connecting WiFi...")
wifi.setmode(wifi.STATION) 
wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        tmr.stop(1)
        print(string.format("WiFi connection established, IP address: %s, MAC: %s", wifi.sta.getip(), wifi.sta.getmac()))
        print("You have 3 seconds to abort")
        print("Waiting...")
        tmr.alarm(0, 3000, 0, startup)
    end
end)
