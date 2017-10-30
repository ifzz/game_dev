
local skynet = require "skynet.manager"
local global = require "global"
local gamedb = import("service.gamedb.gamedbobj")

skynet.start(function()
    local mConfig = {host="127.0.0.1", port="27017"}
    global.oGameDb = gamedb.NewGameDbObj(mConfig, "game")

    --TODO ensure index

    skynet.register(".gamedb")
    skynet.error("gamedb service booted")
end)
