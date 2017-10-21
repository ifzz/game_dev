local module = {}

function import(file_name)
    if module[file_name] then
        return module[file_name]
    end
    local o = loadfile_ex(file_name)
    if o then
        module[file_name] = o
        return o
    end
end

function reload(file_name)
    if not module[file_name] then
        return
    end
    --TODO 热更新
end
