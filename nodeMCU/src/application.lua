dht = require("dht")


-- Constants
SENSOR_PIN = 2
TOPIC_TELEMETRY = "telemetry/"..HONO_TENANT.."/"..HONO_DEVICE_ID
TOPIC_EVENT = "event/"..HONO_TENANT.."/"..HONO_DEVICE_ID


m = mqtt.Client(HONO_DEVICE_ID, 120)

function publish(data, isEvent)
    local topic, qos
    if (isEvent) then
        topic, qos = TOPIC_EVENT, 1
    else
        topic, qos= TOPIC_TELEMETRY, 0
    end

    if (m:publish(topic, data, qos, 1)) then
        print(string.format("Published on topic %q: %s", topic, data))
    else
        print(string.format("Failed to publish on topic %q", topic))
    end
end

function connect_mqtt()
    if wifi.sta.status() == 5 then
        m:connect(HONO_HOST, HONO_MQTT_ADAPTER_PORT, 0, 1,
            function(conn)
                print("Connected to ".. HONO_HOST ..":".. HONO_MQTT_ADAPTER_PORT .." with device-ID '".. HONO_DEVICE_ID .."'")
                publish(string.format("{'startup':'%s'}", wifi.sta.getip()), true)
                sensors_loop()
            end,
            function(client, reason) print("Connection to Hono failed. Reason: "..reason) end)
    else
        print("Connecting to Hono...")
    end
end

function encode_json(table)
    local ok, json = pcall(cjson.encode, table)
    if ok then
        return json
    else
        print("Failed to encode table")
        return nil
    end
end

function read_sensors()
    local status, temp, humi = dht.read(SENSOR_PIN)
    if status == dht.OK then
        return encode_json({Temperature = temp, Humidity = humi, Uptime = tmr.time()})
    elseif status == dht.ERROR_CHECKSUM then
        print("DHT Checksum error.")
    elseif status == dht.ERROR_TIMEOUT then
        print("DHT timed out.")
    end
    return nil
end

function sensors_loop()
    tmr.stop(0)
    local sensor_data = read_sensors()
    if (sensor_data ~= nil) then
        publish(sensor_data, false)
    end

    tmr.alarm(0, UPDATE_RATE_MS, 1, function() sensors_loop() end)
end

connect_mqtt()
