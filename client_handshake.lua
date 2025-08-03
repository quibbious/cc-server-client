-- client_handshake.lua

local modem = peripheral.find("modem", rednet.open)

function _HostClient(protocol, hostname)
    rednet.host(protocol, hostname)
end

function _InitHandshake (protocol,hostname)
    hostname = io.read() or error("please enter a hostname.")
    if not peripheral.find("modem") then 
        _G.printError("no modem attached")
    end
    -- PROTOCOL: "DNS/CUSTOM"
    -- HOSTNAME: "webaddr" (essentially)
    local search_timeout_alarm = os.startTimer(5)
    while true do
         
        
        SERVER_ID = rednet.lookup(protocol, hostname) -- find the server
        if SERVER_ID then
            local times_sent = 0 
            print("Found server at '" .. hostname .. "' on protocol: " .. protocol .. ". ")
            ::start_handshake:: -- BAD CODE PRACTICE
            if times_sent >= 3 then
                break
            end
            rednet.send(SERVER_ID, "quibb.client.handshake_synchronize", "dns") -- send a 'ping' to the server
            times_sent = times_sent + 1
            --print("quibb.client.handshake_synchronize")
            local unused, message = rednet.receive("dns", 5)
            if message == "quibb.server.handshake_synchronize_ack" then 
                rednet.send(SERVER_ID, "quibb.client.handshake_success", "dns")
                print("quibb.client.handshake_success")
                break
            elseif message == nil then
                if times_sent == 4 then
                    print("Server '" .. SERVER_ID.. "' is not responding. sending backup handshake #" .. times_sent)
                elseif times_sent == 3 then
                    print("Server '" .. SERVER_ID.. "' is online but not responding.")
                    break
                end
                goto start_handshake
            end

        else
            local event, id = os.pullEvent("timer")
            if id == search_timeout_alarm then -- if the timeout alarm is done
                print("Server is offline or unregistered.")
                break
            end
        end
    end
    return SERVER_ID
end

_HostClient("dns","testClient")

_InitHandshake("dns","testServer")
