--[[
    数组模块 v1.0
    增强数组的易用性

    创建:雪月灬雪歌 2022/01/27 15:42
]]
local array_data = 
    {
        type = 'array'
    }

local array = {}

--table to array
function array:t2a()
    
end

--新建一个数组
function array:new(...)
    local data = {...}
    local max_i =  #data
    local tmp = {[0] = 0}
    setmetatable(tmp, array_data)
    if max_i > 1 then
        --跳到下面的多个数据处理
    elseif max_i == 1 then  --只有一个参数 或许是table?
        if type(data[1]) == 'table' then
            tmp [1] = table.copy( {}, data[1] )
        else
            tmp[1] = data[1]
        end
        return tmp
    else -- < 1 无参数
        return tmp
    end
    --多个数据：将参数传入的数据加进array
    local count = 0
    for i=1,max_i do
        count = count + 1
        local d = data[i]
        if type(d) == 'table' then
            
        end
        tmp[i] = d
    end
end

--复制数组[只支持数组类型表(即有序表)]
--@param t table 原表
--@param list table 被复制的表
--@return void 返回值直接体现在原表上
function table.copy(t, list)
    if type(t)~='table' or type(list)~='table'then return end --检验参数类型
    local max_list = table.len(list)
    local max_t = table.len(t)
    for i_list,v_list in ipairs(list) do
        max_t = max_t + 1
        t[ max_t ] = list[i_list]
    end
end

--取表长度
--如果table中有[0]索引 默认返回[0](用作储存数组大小)
--和#t不同的是table.len遇到断开的索引就会停止搜索
--@param t table 要取长度的表
function table.len(t)
    if type(t)~='table' then return 0 end --检验参数类型
    local rtn = t[0] or 0
    if rtn == 0 then
        for _,_ in ipairs(t) do
            rtn = rtn + 1
        end
    end
    return rtn
end