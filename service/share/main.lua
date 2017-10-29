local skynet = require "skynet"
local manager = require "skynet.manager"
local sharedata = require "sharedata"

skynet.start(function()
    local fp = io.open(skynet.getenv("sharedata_file"))
    local data = fp:read("a")
    fp:close()
    sharedata.new("share", data)

    manager.register ".share"
    print("share service booted")
end)
