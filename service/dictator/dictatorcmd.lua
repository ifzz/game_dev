------------------------------
--此模块主要用于实现后台指令
------------------------------

function update_code(stdin, print_back, file)
    --TODO 发送到各个服务去执行在线更新
    local dotfile = string.gsub(file, "%/", ".")
    reload(dotfile)
end

function uc(stdin, print_back, file)
    update_code(stdin, print_back, file)
end
