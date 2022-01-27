--[[
    中心计时器模块 v1.1

    创建：雪月灬雪歌    2022/01/25
    修改：雪月灬雪歌    2022/01/26
    test3 
]]

local CreateTimer = cj.CreateTimer
local TimerStart = cj.TimerStart
local mt = {
    type = 'class',
    __id = 0,
    --计时器计数器，不可靠，没使用del销毁的不会减少计数器
    count = 0,
    --队列
    __queue =
        {
            [0] = 0,
        },
    --计时器默认值
            -- 周期数 用来记录当前计时器时间 一个周期 等于 中心计时器 的基本时间
            cycle = 0, 
            maxcycle = 0,

            --回调函数
            callback = nil,

            --间歇 循环型计时器
            interval = false,

            --暂停 通过赋值计时器的pause = true 可以达到暂停计时器
            pause = false,

            --销毁 再下个周期时才会被销毁 可直接赋值true来销毁
            destroy = false,

            --在队列中
            inqueue = false
}
timer = setmetatable({},
    {
        __index = mt,
    }
)
--self: class
--新建计时器
-- -@return timer
function mt:new()
    mt.__id = mt.__id + 1
    mt.count = mt.count + 1
    local t = {
        type = 'timer',
        --ID
        id = mt.__id,
    }
    return setmetatable(t, 
        {
            __index = timer
        }
    )
end

--self: timer|class
--启动计时器[如果没新建计时器系统会自动新建一个并返回]
--@param interval boolean 是否周期执行
--@param time number 时间 秒计算
--@param callback function 计时器回调函数
--@return timer
function mt:timer( interval, time, callback )
    if type(time) ~='number' or type(callback) ~= 'function' then
        return nil
    end
    local cycle = time * 100
    if self.type ~= 'timer' then
        self = self:new()
    end
    self.cycle = 0
    self.maxcycle = cycle
    self.interval = interval
    self.pause = false
    self.destroy = false
    self.callback = callback
    if not self.inqueue then --不在队列中 加入队列
        self.inqueue = true
        mt.__queue[0] = mt.__queue[0] + 1
        mt.__queue[mt.__queue[0]] = self
    end
    return self
end

--self:timer|class
--启动计时器[一次][如果没新建计时器系统会自动新建一个并返回]
--@param time number 时间 按秒计算
--@param callback function 计时器回调函数
--@return timer
function mt:once(time, callback)
    self = self:timer(false, time, callback)
    return self
end
--self:timer|class
--启动计时器[循环][如果没新建计时器系统会自动新建一个并返回]
--@param time number 时间 按秒计算
--@param callback function 计时器回调函数
--@return timer
function mt:loop(time,callback)
    self = self:timer(true, time, callback)
    return self
end
--self: timer
--销毁计时器
function timer:del()
    self.destroy = true
end
--self:timer
--计时器剩余时间
function timer:remain()
    local cycle = self.maxcycle - self.cycle
    return math.max( 0, cycle / 100 )
end
--self:timer
--计时器已流逝时间
function timer:elapsed()
    local cycle = self.cycle
    return math.max( 0, cycle / 100 )
end
--self:timer
--计时器到期时间
function timer:timeout()
    local cycle = self.maxcycle
    return math.max( 0, cycle / 100 )
end

--@private
--中心计时器
local function timer_callback()
    local __queue = mt.__queue
    local i,max_i = 1,__queue[0]
    local offset,t = 0 --引入偏移值offset 去掉table.remove 优化效率 2022/01/26 21:32 雪歌
    while i <= max_i do
        ----偏移值处理：删除有序表的值 同时使后面的值自动补前
            if offset > 0 then 
                    --存在偏移值:将后面的队列前移
                    t = __queue[ i ]
                    __queue[ i ] = nil
                    __queue[i - offset] = t
            else
                    t = __queue[ i ]
            end
        ----中心计时器处理
            if t.destroy then --标记销毁
                    setmetatable(t,nil)
                    offset = offset + 1
                    mt.count = mt.count - 1
            elseif t.pause then --暂停
                offset = offset + 1
            else
                    t.cycle = t.cycle + 1
                    if t.cycle >= t.maxcycle then
                            local status, sErr = xpcall(t.callback, debug.traceback, t)
                            if status then
                                    if not t.interval then
                                            offset = offset + 1
                                    end
                            else
                                    print(sErr)
                            end
                    end
            end
            i = i + 1
    end
    __queue[0] = max_i - offset --数组大小记录
end
local t =timer:once(0.01,function() end)
t:
TimerStart(CreateTimer(), 0.01, true, timer_callback)
return timer