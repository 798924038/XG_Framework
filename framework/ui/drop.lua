--[[
    BACKDROP背景 - 底层控件 经常被其他控件包含 例如 按钮 作为按钮图标
]]
local mt = {}
local base = require 'Framework.UI.Base'
local __add = base.__add__

local DzCreateFrameByTagName = japi.DzCreateFrameByTagName
local DzFrameSetTexture = japi.DzFrameSetTexture
function mt:del()
    self:Event_Remove()
    
    setmetatable(self,nil)
    
    --清除表内容
    self.__data = nil
    self.__base = nil
    self.name = nil
    self.class = nil
    
    self.image= nil
    self.flag = nil
end
function mt:new (parm)
    local base = base:new()
    local data = {}
    data = {
            --定制 预留接口
            __data = data,
            __base = base,
            
            --常量
            class = 'drop', --类型
            
            --控件变量
            image = '', --DROP图像
            flag = 0, -- 0拉伸 1平铺 2左上
        }
        
    setmetatable(data, 
        {
            __index = base,
            __newindex = function(t,k,v)
                    if base[k]~=nil and v ~= nil then
                            base[k] = v
                    else
                            rawset(t, k, v) -- 不能直接使用赋值，因为会出现死循环，要使用rawset
                    end
            end,
        }
    )
    local t = {}
    setmetatable(t,
        {
            __index = function (t,k)
                    return mt[k] or data[k]
            end,
            __newindex = function (t,k,v)
                    if k == 'image' then
                        DzFrameSetTexture( data.frame, v, data.flag or 0 )
                        data.image = v
                    elseif k == 'flag' then
                        DzFrameSetTexture( data.frame, data.image, v or 0 )
                        data.flag = v
                    else
                        
                        data[k] = v
                        
                    end
                    
            end,
            __add = function(t,nt) -- example: text:Create() + { x = 0.2, y = 0.1 } 
                    if type(nt) ~= 'table' then return t end
                    for k,v in ipairs(__add) do
                        if nt[ v ] then
                            t [ v ] = nt [ v ]
                        end
                    end
                    return t
            end,
        }
    )
    if type(parm) ~= 'table' then
        parm = {}
    end
    parm.name = parm.name or NewName()
    

    t.frame = DzCreateFrameByTagName( "BACKDROP", t.name, t.parent, t.template, t.id )
    t.obj = t
    
    t = t + parm
    
    return t
end
--UI注册事件 同步事件必须同步注册
function mt:Event( event, sync ,func )
    self.__base:Event(event, sync, func)
end
return mt
