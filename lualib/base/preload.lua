local skynet = require "skynet"


print = function(...)
    local info_list = table.pack(...)
    local ret_list = {}
    for i = 1, #info_list do
        if info_list[i] == "nil" then
            table.insert(ret_list, "nil")
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

trace_msg = function()
    print(debug.traceback("=====safe_call====="))
end

safe_call = function(func, ...)
    xpcall(func, trace_msg, ...)
end

loadfile_ex = function(file_name, trunk_name, mode, env)
    local fp = io.open(file_name, "bt")
    local content = fp:read("a")
    fp:close()
    local ret, f = safe_call(load, content, trunk_name, mode, env)
    if ret then
        m = f()
        return m
    else
        assert(nil, "loadfile_ex err" .. file_name)
    end
end


require "base.reload"
