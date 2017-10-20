local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("debug_console", 7001)
    skynet.newservice("dictator")
--    skynet.newservice "world"
--    skynet.newservice "gamedb"
--    skynet.newservice "share"
end)
