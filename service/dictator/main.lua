local skynet = require "skynet"
local socket = require "socket"
local manager = require "skynet.manager"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"

COMMAND = {}
COMMAND.update_code = function(stdin, print_back, module_list)
    --TODO execute reload file
end

function dictator_main_loop(stdin, print_back)
    print_back("Welcome to skynet dictator")
    pcall(function()
        while true do
            local cmdline = socket.readline(stdin, "\n")
            if not cmdline then break end

            if cmdline:sub(1, 4) == "GET " then
                local code, url = httpd.read_request(sockethelper.readfunc(stdin, cmdline.."\n"), 8192)
                local cmdline = url:sub(2):gsub("/", " ")
                docmd(cmdline, print_back, stdin)
                break
            end
            if cmdline ~= "" then
                docmd(cmdline, print_back, stdin)
            end
        end
    end)
--    skynet.error(stdin, "disconnected")
--    socket.close(stdin)
end

local function docmd(cmdline, print_back, stdin)
	local split = split_cmdline(cmdline)
	local command = split[1]
	local cmd = COMMAND[command]
	local ok, list
	if cmd then
		ok, list = pcall(cmd, stdin, print_back, select(2,table.unpack(split)))
	else
		print_back("Invalid command, type help for command list")
	end

	if ok then
		if list then
			if type(list) == "string" then
				print(list)
			else
				dump_list(print_back, list)
			end
		else
			print_back("OK")
		end
	else
		print_back("Error:", list)
	end
end

skynet.start(function()
    local iPort = skynet.getenv("dictator_port") or 7002

    local fd = socket.listen("127.0.0.1", iPort)
    socket.start(fd, function(id, addr)
        local function print_back(...)
            local t = { ... }
            for k, v in ipairs(t) do
                t[k] = tostring(v)
            end
            socket.write(id, table.concat(t, "\t"))
            socket.write(id, "\n")
        end
        socket.start(id)
        skynet.fork(dictator_main_loop, id, print_back)
    end)
    manager.register(".dictator")
    skynet.error("dictator service booted")
end)
