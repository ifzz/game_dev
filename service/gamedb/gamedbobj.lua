local skynet = require "skynet"
local mongo = require "mongo"
local baseobj = import(lualib_path("base.baseobj"))

function NewGameDbObj(...)
    return CGameDb:New(...)
end


CGameDb = {}
CGameDb.__index = CGameDb
inherit(CGameDb, baseobj.CBaseObj)

function CGameDb:New(mConfig, sDbName)
    local o = super(CGameDb).New(self)
    o.m_oClient = nil
    o.m_sDbName = sDbName
    o:Init(mConfig)
    return o
end

function CGameDb:Init(mConfig)
    local oClient = mongo.client(mConfig)
    self.m_oClient = oClient
end

function CGameDb:GetDb()
    return self.m_oClient:getDB(self.m_sDbName)
end

function CGameDb:Insert(...)
    local obj = self:GetDb()
    obj:insert(...)
end

function CGameDb:Update(mCond, mUpdate, bUpsert, bMulti)
    local obj = self:GetDb()
    obj:update(mCond, mUpdate, bUpsert, bMulti)
end

function CGameDb:Delete(mCond, bSingle)
    local obj = self:GetDb()
    --TODO supply
end

function CGameDb:FindOne(mQuery, mSelect)
    local obj = self:GetDb()
    local m = obj:findOne(mCond, mSelect)
    --TODO supply
    return m
end

function CGameDb:Find(mQuery, mSelect)
    local obj = self:GetDb()
    local m = obj:find(mQuery, mSelect)
    --TODO supply
    return m
end

function CGameDb:EnsureIndex(...)
    local obj = self:GetDb()
    obj:createIndexes(...)
end

function CGameDb:FindAndModify(mConf)
    local obj = self:GetDb()
    obj:findAndModify(mConf)
end
