local modem = peripheral.find("modem", rednet.open)

function _HostServer(protocol, hostname)
    rednet.host(protocol, hostname)
    return true
end

function _InitHandshake ()
    local CLIENT_ID
    if not peripheral.find("modem") then 
        _G.printError("no modem attached")
    end
    -- PROTOCOL: "DNS/CUSTOM"
    -- HOSTNAME: "webaddr" (essentially)
    while true do
        term.setCursorBlink(true) -- to show not hung
        CLIENT_ID, message = rednet.receive("dns",30) -- wait for client, 60sec timeout
        if CLIENT_ID then 
            print("Found client '" .. CLIENT_ID .. "'")
            if message == "quibb.client.handshake_synchronize" then
                rednet.send(CLIENT_ID, "quibb.server.handshake_synchronize_ack", "dns")
                local unused, handshake = rednet.receive("dns", 15)
                if handshake == "quibb.client.handshake_success" then
                    print("quibb.server.local: successful handshake with '".. CLIENT_ID .. "'. ")
                    break
                end
            end
        end
    end
    return CLIENT_ID
end

_HostServer("dns","AudioServer")

_InitHandshake()
