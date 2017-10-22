function table_copy(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[k] = v
    end
    return res
end

function table_deep_copy(tbl)
    --TODO
    return tbl
end

function table_serialize(tbl, visited)
    visited = visited or {}
    local con = "{"
    for k, v in pairs(tbl) do
        if not visited[k] or visited[k] ~= v then
            visited[k] = v
            if type(k) == "table" then
                con = con.."["..table_serialize(k, visited).."] = "
            elseif type(k) == "number" then
                con = con.."["..tostring(k).."] = "
            else
                con = con..tostring(k).." = "
            end
            if type(v) == "table" then
                con = con..table_serialize(v, visited)
            else
                con = con .. tostring(v)
            end
            con = con .. ", "
        end
    end
    con = con .. "}"
    return con
end
