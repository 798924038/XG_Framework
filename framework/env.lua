-- -- -- -- -- -- -DEBUG-- -- -- -- -- -- -- -
print = require ("jass.console").write
local o_require = require
require = function(lib)
    print('require ',lib,' Init...')
    local tmp = o_require(lib)
    print('require ',lib,' Inited')
    return tmp
end
require ("jass.runtime").sleep = false
require ("jass.console").enable = true
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
cj = require "jass.common"
hook = require "jass.hook"
japi=require('jass.japi')
G = require 'jass.globals'
__ENV = {} --自定义全局环境表 支持函数 和 值
setmetatable(_G,
    {
        __index = function(t,k)
            local rtn = cj[k] or japi[k] or G[k]
            return rtn
        end
    }
)
function string.split(str, split_char)--分割字符串
    if not(str and split_char) then return {} end
    local sub_str_tab = {}
    while true do 
        local pos,pos2 = string.find(str, split_char,1,true) --四号参数 设为true 则作为普通文本处理 而不是模式匹配
        if not pos then 
            table.insert(sub_str_tab,str)
            break
        end 
        local sub_str = string.sub(str, 1, pos - 1) 
        table.insert(sub_str_tab,sub_str)
        str = string.sub(str, pos2 + 1, string.len(str))
    end
    return sub_str_tab
end
function B2I(b)
    if b then
        return 1
    end
    return 0
end
function I2B(i)
    if i==0 then
        return false
    end
    return true
end
