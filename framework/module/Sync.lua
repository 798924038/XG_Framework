--[[
    同步模块 v1.1

    依赖模块/函数特别说明
        string.split(str, s) 分割字符串

    雪月灬雪歌  2022/01/27  14:57
]]

local DzSyncData = japi.DzSyncData
local DzTriggerRegisterSyncData = japi.DzTriggerRegisterSyncData
local DzGetTriggerSyncData = japi.DzGetTriggerSyncData

--sync_data
local sync_data = {
    type = 'sync_data',
}
sync_data.__index = sync_data
sync_data.__call = function(t)
	return table.concat(t,"&")
end
--sync class
sync = setmetatable({},{
    type = 'class',
    class = 'sync',
})

local __callback = {}

--中心分发器传参用
local package = setmetatable( {}, sync )
local trg = cj.CreateTrigger() --同步模块中心分发器
local SYNC_SYSTEM_TAG = 'XG_SYNC'

--self:class
--生成同步数据包
--@param d any 任意个数据，但注意 如果添加的是一张表，只会检索一层表
--@return sync_data 返回一个同步数据包
function sync:new(d) 
    local t = setmetatable( {
        [1] = "", --默认同步标签占位
    }, sync_data )
    if d~=nil then t:Add(d) end
    return t
end

--self:class
--解析同步数据包
function sync:load()
	return package
end

--self:class
--注册同步回调[]
--@param tag string 回调标签
--@param func function 回调函数
function sync:callback(tag,func)
    if type(func) ~= 'function' then return end
    if not __callback [tag] then
        __callback [tag] = { [0] = 1, func }
    else
        local m = __callback [tag] [0]

        table.insert( __callback [tag] , func )
    end
    return func
end


--self:sync_data
--往同步数据包内添加数据
--@Param ... any 任意个数据，但注意 如果添加的是一张表，只会检索一层表
function sync_data:Add(...)
	local d = { ... }
	for i=1,#d do
		local p = type(d[i])
		if p == 'nil' then
		elseif p == 'string' then
			table.insert(self,d[i])
		elseif p == 'table' then
			for j=1,#d[i] do
				table.insert(self,tostring(d[i][j]))
			end
		else
			table.insert(self,tostring(d[i]))
		end
	end
end

--self:sync_data
--发送同步数据包
--@param tag string 同步标签，你需要使用sync(class)注册一个同步回调
function sync_data:Send(tag)
    self[1] = tag
	DzSyncData( SYNC_SYSTEM_TAG, self( ) )
end

--@private
--模块中心分发器
DzTriggerRegisterSyncData(trg, SYNC_SYSTEM_TAG, false)
local function action()
    --package可用于传参 回调中使用 sync:load() 可载入同步数据包
    package = ( DzGetTriggerSyncData() or '' ):split( "&" )
    local tag = package [ 1 ] or ''
    table.remove(package, 1) --移除同步标签
    setmetatable( package, sync_data )

    for i,v in ipairs( __callback [tag] ) do
        v ( )
    end

end
cj.TriggerAddAction( trg, action )
