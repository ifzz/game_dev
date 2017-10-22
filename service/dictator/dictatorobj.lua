local skynet = require "skynet"
local baseobj = import("lualib.base.baseobj")

function NewDictatorObj(...)
    return CDictator:New(...)
end


CDictator = {}
CDictator.__index = CDictator
inherit(CDictator, baseobj.CBaseObj)

function CDictator:New(...)
    local o = super(CDictator).New(self)
    o.m_mServer = {}
    o.m_mInit = {}
    return o
end


