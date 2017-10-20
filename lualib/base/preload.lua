local skynet = require "skynet"

require "base.reload"

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
