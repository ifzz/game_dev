
MY_ADDR = ...

local skynet = require "skynet"
require "base.tableop"

print = function(...)
    local info_list = table.pack(...)
    local ret_list = {}
    for i = 1, #info_list do
        if info_list[i] == "nil" then
            table.insert(ret_list, "nil")
        elseif type(info_list[i]) == "table" then
            table.insert(ret_list, table_serialize(info_list[i]))
        else
            table.insert(ret_list, info_list[i])
        end
    end
    skynet.error(table.unpack(ret_list))
end

inherit = function(children, parent)
    setmetatable(children, parent)
end

super = function(class)
    return getmetatable(class)
end

trace_msg = function(msg)
    print(debug.traceback("=====" .. msg .. "====="))
end

safe_call = function(func, ...)
    xpcall(func, trace_msg, ...)
end

loadfile_ex = function(file_name, mode, env)
    mode = mode or "rb"
    local fp = io.open(file_name, mode)
    local data = fp:read("a")
    fp:close()
    local f, s = load(data, file_name, "bt", env)
    assert(f, s)
    return f
end

require "base.reload"
