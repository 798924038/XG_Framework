--[[
    按钮 - 组合控件 主要由DROP + TEXT组成
]]
local mt = {}
local base = require 'Framework.UI.Base'
local __add = base.__add__

local DzCreateFrameByTagName = japi.DzCreateFrameByTagName
function mt:del()
    self:Event_Remove()
    
    setmetatable(self,nil)
    
    --清除表内容
    self.__data = nil
    self.__base = nil
    self.name = nil
    self.class = nil
    
    self.icon:del()
    self.text:del()
    self.contour:del()
    self.icon = nil
    self.text = nil
    self.contour = nil
end
function mt:Create (parm)
    local text = require 'Framework.UI.TEXT'
    local drop = require 'Framework.UI.DROP'
    
    local base = base:new()
    local data = {}
    data = {
            --定制 预留接口
            __data = data,
            __base = base,
            
            --常量
            class = 'button', --类型
            
            --控件变量
            
            icon = drop:new(), --按钮的背景
            text = text:new(), -- 按钮文本
            contour = drop:new(), --外形框 用来限制轮廓 比如做平行四边形的按钮
        }
        
    setmetatable(data, 
        {
            __index = function(t,k)
                    local c = rawget(data,k)
                    if c then
                        return c
                    else
                        return base[k]
                    end
            end,
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
                    if k == 'absPoint' then
                        data.contour[k] = v
                        data.text[k] = v
                        data.icon[k] = v
                    elseif k =='x' then
                        data.contour[k] = v
                        data.text[k] = v
                        data.icon[k] = v
                    elseif k =='y' then
                        data.contour[k] = v
                        data.text[k] = v
                        data.icon[k] = v
                    elseif k =='width' then
                        data.contour[k] = v
                        data.text[k] = v
                        data.icon[k] = v
                    elseif k =='height' then
                        data.contour[k] = v
                        data.text[k] = v
                        data.icon[k] = v
                    elseif k == 'enable' then
                        data.text[k] = v
                    elseif k == 'visible' then
                        data.icon[k] = v
                    elseif k == 'value' then
                        data.text[k] = v
                    elseif k == 'font' then
                        data.text[k] = v
                    elseif k == 'textsize' then
                        data.text[k] = v
                    elseif k == 'align' then
                        data.text[k] = v
                    elseif k == 'image' then
                        data.icon.image = v
                    elseif k == 'flag' then
                        data.icon.flag = v
                    elseif k =='contour' then
                        data.contour.image = v
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
    
    --t.icon.parent = t.contour.frame
    t.text.parent = t.icon.frame
    t.contour = "contour.tga"
    t.obj = t
    
    t = t + parm
    
    return t
end
--UI注册事件 同步事件必须同步注册
function mt:Event( event, sync ,func )
    self.__base:Event(event, sync, func)
end
return mt
