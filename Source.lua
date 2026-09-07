local UModule = {}

local vgs = {
    CE = game:GetService("ReplicatedStorage").CharacterEvents,
    CAS = game:GetService("ContextActionService"),
    VIM = game:GetService("VirtualInputManager"),
    p = game:GetService("Players").LocalPlayer,
    RS = game:GetService("ReplicatedStorage"),
    UIS = game:GetService("UserInputService"),
    TXS = game:GetService("TextChatService"),
    RF = game:GetService("ReplicatedFirst"),
    PS = game:GetService("PhysicsService"),
    TS = game:GetService("TweenService"),
    RunS = game:GetService("RunService"),
    SG = game:GetService("StarterGui"),
    Debris = game:GetService("Debris"),
    ps = game:GetService("Players"),
}

local gtable = getgenv()

UModule.env = setmetatable({}, {
    __newindex = function(t, key, value)
        local old = gtable[key]
        
        if old ~= nil then
            if type(old) == "boolean" then
                gtable[key] = false
                gtable[key] = nil
                gtable[key] = value
                return
            end
            if type(old) == "string" then
                gtable[key] = nil
            end
            
            if type(old) == "userdata" or (type(old) == "table" and type(rawget(old, "Disconnect")) == "function") then
                pcall(function()
                    old:Disconnect()
                end)
                gtable[key] = nil
            elseif type(old) == "table" then
                for k, v in pairs(old) do
                    if type(v) == "boolean" then
                        old[k] = false
                        old[k] = nil
                    elseif type(v) == "string" then
                        old[k] = nil
                    elseif type(v) == "userdata" or (type(v) == "table" and type(rawget(v, "Disconnect")) == "function") then
                        pcall(function()
                            v:Disconnect()
                        end)
                        old[k] = nil
                    end
                end
            end
        end
        
        gtable[key] = value
    end,
    __index = function(t, key)
        return gtable[key]
    end
})

UModule.env.ov = {
    char = vgs.p.Character or vgs.p.CharacterAdded:Wait(),
    inv = workspace[vgs.p.Name .. "SpawnedInToys"],
    cam = workspace.CurrentCamera,
    mouse = vgs.p:GetMouse(),
}

UModule.env.Connections = UModule.env.Connections or {}
UModule.env.Valores = UModule.env.Valores or {}
UModule.env.Toggle = UModule.env.Toggle or {}
UModule.env.Timers = UModule.env.Timers or {}
UModule.env.Conns = UModule.env.Conns or {}
UModule.env.TempV = UModule.env.TempV or {}
UModule.env.TempL = UModule.env.TempL or {}
UModule.env.TempT = UModule.env.TempT or {}
UModule.env.TempC = UModule.env.TempC or {}
UModule.env.Drops = UModule.env.Drops or {}
UModule.env.Lists = UModule.env.Lists or {}
UModule.env.Vars = UModule.env.Vars or {}
UModule.env.l = UModule.env.l or {}
UModule.env.v = UModule.env.v or {}

UModule.env.fpsval = 60

if not UModule.env.fpstrack then
    UModule.env.fpstrack = vgs.RunS.RenderStepped:Connect(function(dt)
        if dt > 0 then
            local raw = math.floor(1 / dt)
            UModule.env.fpsval = math.min(raw, 9999)
        end
    end)
end

function UModule.fps()
    return UModule.env.fpsval
end

if UModule.env.Conns.CharAddCnn then
    UModule.env.Conns.CharAddCnn = nil
end
UModule.env.Conns.CharAddCnn = vgs.p.CharacterAdded:Connect(function(char)
    UModule.env.ov.char = char
end)

function UModule.p(...)
    local args = {...}
    local name, model, time
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "string" then
            name = arg
        elseif t == "number" then
            time = arg
        elseif typeof(arg) == "Instance" then
            model = arg
        end
    end
    
    if not name or not model then return nil end
    
    if time then 
        return model:WaitForChild(name, time) 
    else 
        return model:FindFirstChild(name) 
    end
end

function UModule.MBP(name)
    local char = UModule.env.ov.char
    return char:FindFirstChild(name) or char:WaitForChild(name)
end

function UModule.inpast(model)
    return workspace[vgs.p.Name .. "SpawnedInToys"]:FindFirstChild(model)
end

function UModule.GPNames(mode, arg)
    local pnames = {}
    if mode == "func" then
        for _, p in ipairs(vgs.ps:GetPlayers()) do
            if p ~= vgs.p and not arg() then
                table.insert(pnames, p.Name .. " (" .. p.DisplayName .. ")")
            end
        end
        return pnames
    end
    for _, p in ipairs(vgs.ps:GetPlayers()) do
        if p ~= vgs.p then
            table.insert(pnames, p.Name .. " (" .. p.DisplayName .. ")")
        end
    end
    return pnames
end

function UModule.SPE(pt, loc, cf, ang)
    if pt and loc and cf then
        vgs.RS.PlayerEvents.StickyPartEvent:FireServer(
            pt, 
            loc, 
            cf * ang or CFrame.Angles(0, 0, 0)
        )
    end
end

function UModule.SVel(...)
    local args = {...}
    local target
    
    for _, arg in ipairs(args) do
        if typeof(arg) == "Instance" then
            target = arg
            break
        end
    end
    
    if target then
        if target:IsA("BasePart") then
            target.Velocity = Vector3.zero
            target.RotVelocity = Vector3.zero
            return 
        elseif target:IsA("Model") then
            for _, part in ipairs(target:GetDescendants()) do
                if part:IsA("BasePart") then  
                    part.Velocity = Vector3.zero
                    part.RotVelocity = Vector3.zero
                end
            end
            return 
        end
    end
    
    local hrp = UModule.MBP("HumanoidRootPart")
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
end

function UModule.FINF()
    local uray = UModule.env.ov.cam:ScreenPointToRay(UModule.env.ov.mouse.X, UModule.env.ov.mouse.Y)
    if not uray then return nil end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {UModule.env.ov.char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(uray.Origin, uray.Direction * 10000, params)
    
    if result and result.Instance:IsA("BasePart") then
        return result.Instance
    end
    
    return nil
end

function UModule.IPPP(part, mode)
    local function isin(p, m)
        return m and p:IsDescendantOf(m) or false
    end
    
    local function cfolder(name)
        return isin(part, workspace:FindFirstChild(name))
    end
    
    local function cgrab()
        if isin(part, workspace:FindFirstChild("GrabParts")) then return true end
        
        for _, char in pairs(workspace:GetChildren()) do
            if char:IsA("Model") and char ~= UModule.env.ov.char then
                if isin(part, char:FindFirstChild("GrabParts")) then return true end
            end
        end
        return false
    end
    
    local protected = cfolder("Map") or cfolder("Plots") or cfolder("Slots") 
        or cgrab() or part:IsDescendantOf(UModule.env.ov.char)
    
    if mode == 2 and part:IsDescendantOf(UModule.env.ov.inv) then
        return true
    end
    
    return protected
end

function UModule.tp(target)
    local hrp = UModule.MBP("HumanoidRootPart")
    local pos = typeof(target) == "Vector3" and target or 
            (target:IsA("Model") and (target:GetPrimaryPartCFrame().Position or 
            target:FindFirstChild("HumanoidRootPart").Position) or target.Position)
    
    if not pos then return end
    
    local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
    local hip = hum and hum.HipHeight or 0
    local offset = (hrp.Size.Y / 2) + hip + 3.5
    local current = hrp.Parent:GetPivot()
    
    hrp.Parent:PivotTo(CFrame.new(pos.X, pos.Y + offset, pos.Z) * (current - current.Position))
end

function UModule.SICF(...)
    local args = {...}
    task.spawn(function()
        local item, cf, mode
        
        for i = 1, #args do
            local arg = args[i]
            if arg ~= nil then
                local t = type(arg)
                if t == "string" then
                    if not item then
                        item = arg
                    else
                        mode = arg
                    end
                elseif typeof(arg) == "CFrame" then
                    cf = arg
                end
            end
        end
        
        if not item then return end
        
        local hrp = UModule.env.ov.char:WaitForChild("HumanoidRootPart")
        local rotation = Vector3.zero

        if mode == "Default" then
            cf = hrp.CFrame
        elseif mode == "Head" then
            cf = CFrame.new(hrp.Position + Vector3.new(0, 20, 20))
        elseif mode == "Front" then
            cf = hrp.CFrame * CFrame.new(0, 0, 15)
        end
        
        cf = cf or hrp.CFrame
        vgs.RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(item, cf, rotation)
    end)
end

function UModule.IsAround(part, radius)
    local hrp = UModule.env.ov.char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos = part:IsA("Model") and part.PrimaryPart.Position or part.Position
    return (pos - hrp.Position).Magnitude <= radius
end

function UModule.FMC(...)
    local args = {...}
    local radius, cback, flag, origin
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "number" then
            radius = arg
        elseif t == "function" then
            cback = arg
        elseif t == "string" and arg == "plrs" then
            flag = "plrs"
        elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then
            origin = arg
        end
    end
    
    if flag == "plrs" then
        local char = vgs.p.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        radius = radius or 29
        
        for _, player in ipairs(vgs.ps:GetPlayers()) do
            if player.Character and player ~= vgs.p then
                local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                if phrp and UModule.IsAround(phrp, radius) then
                    if cback then cback(player.Character) end
                end
            end
        end
        return
    end
    
    if not radius then
        if typeof(args[1]) == "Instance" then
            local char = args[1]:FindFirstAncestorOfClass("Model")
            return char and char:FindFirstChild("Humanoid") and vgs.ps:GetPlayerFromCharacter(char) or nil
        end
        return nil
    end
    
    local char = vgs.p.Character
    if not char then return {} end
    
    local hrp = origin or char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local results, seen = {}, {}
    local filter = {char}
    
    local exclude = {"Map", "Plots", "Slots", "GrabParts"}
    for _, name in ipairs(exclude) do
        local obj = workspace:FindFirstChild(name)
        if obj then table.insert(filter, obj) end
    end
    
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model ~= char then
            local gp = model:FindFirstChild("GrabParts")
            if gp then table.insert(filter, gp) end
        end
    end
    
    if flag ~= 2 then
        local inv = workspace:FindFirstChild(vgs.p.Name .. "SpawnedInToys")
        if inv then table.insert(filter, inv) end
    end
    
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local parts = workspace:GetPartBoundsInBox(
        CFrame.new(hrp.Position), 
        Vector3.new(radius * 2, radius * 2, radius * 2), 
        params
    )
    
    for _, part in ipairs(parts) do
        if not UModule.IPPP(part, flag) then
            local model = part:FindFirstAncestorOfClass("Model")
            
            if cback then
                if model and cback(model) and not seen[model] then
                    seen[model] = true
                    table.insert(results, model)
                end
            else
                if model and not seen[model] then
                    seen[model] = true
                    table.insert(results, model)
                elseif not model and not seen[part] then
                    seen[part] = true
                    table.insert(results, part)
                end
            end
        end
    end
    
    return results
end

function UModule.var(a1, a2, a3)
    if type(a1) == "table" and a2 == nil then
        for k, v in pairs(a1) do
            UModule.env[k] = v
        end
        return true
    end

    if type(a1) == "string" and a2 == nil and a3 == nil then
        if UModule.env[a1] ~= nil then return UModule.env[a1] end
        for _, tbl in pairs(UModule.env) do
            if type(tbl) == "table" and tbl[a1] ~= nil then
                return tbl[a1]
            end
        end
        return nil
    end

    if type(a1) == "string" and a2 ~= nil then
        if a2 == "ref" then
            if not UModule.env[a1] then UModule.env[a1] = {} end
            if type(UModule.env[a1]) == "table" then return UModule.env[a1] end
            return nil
        end

        if a2 == "get" then
            if UModule.env[a1] and type(UModule.env[a1]) == "table" and a3 then
                return UModule.env[a1][a3]
            end
            return UModule.env[a1]
        end

        if a2 == "merge" and type(a3) == "table" then
            if not UModule.env[a1] then UModule.env[a1] = {} end
            if type(UModule.env[a1]) == "table" then
                for k, v in pairs(a3) do UModule.env[a1][k] = v end
            end
            return true
        end

        if a3 ~= nil then
            if not UModule.env[a1] then UModule.env[a1] = {} end
            if type(UModule.env[a1]) ~= "table" then UModule.env[a1] = {} end
            UModule.env[a1][a2] = a3
            return true
        else
            UModule.env[a1] = a2
            return true
        end
    end

    return nil
end

getgenv().var = UModule.var

UModule.tm = {}

function UModule.tm.Add(tbl, key, value)
    if type(tbl) ~= "table" or key == nil then return false end
    
    if value ~= nil then
        tbl[key] = value
    else
        for _, v in pairs(tbl) do
            if v == key then return true end
        end
        table.insert(tbl, key)
    end
    
    return true
end

function UModule.tm.Find(tbl, key)
    if type(tbl) ~= "table" or key == nil then return nil end
    if tbl[key] ~= nil then return tbl[key] end
    
    for i, v in pairs(tbl) do
        if v == key then return i, v end
    end
    
    return nil
end

function UModule.tm.val(tbl, key)
    if type(tbl) ~= "table" or key == nil then return false end
    
    local value = tbl[key]
    
    if value == nil then
        for _, v in pairs(tbl) do
            if v == key then return true end
        end
        return false
    end
    
    return type(value) == "boolean" and value or (value ~= nil and value ~= false)
end

function UModule.tm.Remove(tbl, key)
    if type(tbl) ~= "table" or key == nil then return false end
    
    if tbl[key] ~= nil then
        tbl[key] = nil
        return true
    end
    
    for i, v in pairs(tbl) do
        if v == key then
            if type(i) == "number" then
                table.remove(tbl, i)
            else
                tbl[i] = nil
            end
            return true
        end
    end
    
    return false
end

function UModule.tm.Clear(tbl)
    if type(tbl) ~= "table" then return false end
    for k in pairs(tbl) do tbl[k] = nil end
    return true
end

function UModule.wfc(...)
    local args = {...}
    local name, parent, timeout
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "string" then
            name = arg
        elseif t == "number" then
            timeout = arg
        elseif typeof(arg) == "Instance" then
            parent = arg
        end
    end
    
    if not name then return nil end
    
    parent = parent or UModule.env.ov.char
    
    if not timeout then
        local child
        if not parent:FindFirstChild(name) then
            repeat
                child = parent:FindFirstChild(name)
                if child then return child end
                task.wait()
            until child
        else
            return parent:FindFirstChild(name)
        end
        return child
    end
    
    local startTime = tick()
    local child

    if parent:FindFirstChild(name) then
        return parent:FindFirstChild(name)
    end
    
    repeat
        child = parent:FindFirstChild(name)
        if child then return child end
        task.wait()
    until (tick() - startTime) >= timeout
    
    return nil
end

function UModule.tpm(pos, priority, back, tag)
    local tv = UModule.var("TempV")
    if not tv.tpm then tv.tpm = { saved = {}, queue = {}, busy = false } end
    local t = tv.tpm

    local dest = typeof(pos) == "CFrame" and pos or CFrame.new(pos)

    if back then
        local hrp = UModule.MBP("HumanoidRootPart")
        if t.saved[tag] then dest, t.saved[tag] = t.saved[tag], nil
        elseif hrp then t.saved[tag] = hrp.CFrame end
    end

    table.insert(t.queue, { dest = dest, pri = priority or 0 })

    if t.busy or #t.queue == 0 then return end
    t.busy = true
    table.sort(t.queue, function(a, b) return a.pri < b.pri end)
    task.spawn(function()
        local hrp = UModule.MBP("HumanoidRootPart")
        if hrp then
            local job = table.remove(t.queue, 1)
            hrp.CFrame, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = job.dest, Vector3.zero, Vector3.zero
        end
        t.busy = false
    end)
end

function UModule.tmr(tag, a2, a3)
    local dur = type(a2) == "number" and a2 or (type(a3) == "number" and a3 or nil)
    local cmd = type(a2) == "string" and a2 or (type(a3) == "string" and a3 or nil)

    if not a2 and not a3 then
        return UModule.env.Timers[tag] and UModule.env.Timers[tag]._run or false
    end

    if cmd then
        if not UModule.env.Timers[tag] then return end
        if cmd == "pause" then
            UModule.env.Timers[tag]._pause = true
            UModule.env.Timers[tag]._pt = tick()
        elseif cmd == "resume" then
            if UModule.env.Timers[tag]._pause then
                local pd = tick() - UModule.env.Timers[tag]._pt
                UModule.env.Timers[tag]._et = UModule.env.Timers[tag]._et + pd
                UModule.env.Timers[tag]._pause = false
            end
        elseif cmd == "restart" then
            if dur then
                UModule.env.Timers[tag]._et = tick() + dur
                UModule.env.Timers[tag]._pause = false
            end
        elseif cmd == "stop" then
            UModule.env.Timers[tag]._run = false
            UModule.env.Timers[tag] = nil
        end
        return
    end

    if not dur then return end

    if UModule.env.Timers[tag] then
        UModule.env.Timers[tag]._run = false
    end

    UModule.env.Timers[tag] = {
        _run   = true,
        _pause = false,
        _et    = tick() + dur
    }

    task.spawn(function()
        local t = UModule.env.Timers[tag]
        local remaining = t._et - tick()
        if remaining > 0 then
            task.wait(remaining)
        end
        if t._run and not t._pause then
            t._run = false
            UModule.env.Timers[tag] = nil
        end
    end)
end

function UModule.cm(...)
    local args = {...}
    local Connections = UModule.env.Connections

    if #args == 2 and type(args[1]) == "string" then
        local name, cmd = args[1], args[2]
        local conn = Connections[name]

        if cmd == "disc" or cmd == "disconnect" then
            if conn then
                pcall(conn.Disconnect, conn)
                Connections[name] = nil
            end
            return
        end
        if cmd == "pause" then
            if conn then
                conn._paused = true
                if conn._setPaused then conn._setPaused(true) end
            end
            return
        end
        if cmd == "resume" then
            if conn then
                conn._paused = false
                if conn._setPaused then conn._setPaused(false) end
            end
            return
        end
        if cmd == "status" then
            if not conn then return "none" end
            return conn._paused and "paused" or "active"
        end
        if cmd == "recon" or cmd == "reconnect" then
            if not conn then return end
            local senv    = conn.eventType
            local sprop   = conn.propName
            local savedTtle = conn.ttle
            local oldInst = conn.inst
            local callback = conn._cbacks[1].func
            pcall(conn.Disconnect, conn)

            local ninst = nil
            local nups = debug.getinfo(callback, "u").nups
            for i = 1, nups do
                local _, value = debug.getupvalue(callback, i)
                if type(value) == "function" then
                    local ok, result = pcall(value, oldInst.Name)
                    if ok and typeof(result) == "Instance" then ninst = result break end
                elseif typeof(value) == "Instance" and value.ClassName == oldInst.ClassName then
                    ninst = value break
                end
            end

            if not ninst then
                local ok, char = pcall(function() return vgs.p.Character end)
                if ok and char then ninst = char:FindFirstChild(oldInst.Name) end
            end
            if not ninst then return end

            local reconargs = {ninst, senv}
            if sprop then reconargs[#reconargs+1] = sprop end
            reconargs[#reconargs+1] = callback
            if savedTtle then reconargs[#reconargs+1] = savedTtle end
            reconargs[#reconargs+1] = name
            UModule.cm(table.unpack(reconargs))
            return
        end
        return
    end

    local inst, cback, name, stgs, ttle, once, madd =
        nil, nil, nil, {}, nil, false, false

    local function gfstr(func)
        local info = debug.getinfo(func, "S")
        if info then
            local src = (info.source or "unknown"):gsub("^@", "")
            return src .. ":" .. (info.linedefined or 0) .. "-" .. (info.lastlinedefined or info.linedefined or 0)
        end
        return tostring(func)
    end

    for i = 1, #args do
        local arg = args[i]
        local t = type(arg)
        if typeof(arg) == "Instance" then inst = arg
        elseif t == "function" then cback = arg
        elseif t == "string" then
            if arg == "Add" then madd = true
            elseif arg == "once" or arg == "Once" then once = true
            else stgs[#stgs+1] = arg end
        elseif t == "number" then ttle = arg
        elseif t == "table" then ttle = arg end
    end

    if madd then
        local cname = stgs[1]
        local existing = Connections[cname]
        if not cname or not existing or not cback then return end
        existing._cbacks[#existing._cbacks+1] = {func = cback, once = once, counter = 0, ttle = ttle}
        return existing
    end

    if not inst or not cback then return end

    local event = stgs[1]

    if event == "BindToRenderStep" or event == "BRenderStepped" then 
        local priorityMap = {
            First  = Enum.RenderPriority.First.Value,
            Input  = Enum.RenderPriority.Input.Value,
            Camera = Enum.RenderPriority.Camera.Value,
            Last   = Enum.RenderPriority.Last.Value,
        }

        local fpsLimit = (type(ttle) == "number" or type(ttle) == "table") and ttle or nil

        local priority = type(ttle) == "number" and Enum.RenderPriority.Last.Value
            or priorityMap[ttle]
            or Enum.RenderPriority.Last.Value

        name = stgs[2] or ("brs_" .. tick())

        if Connections[name] then
            pcall(function() vgs.RunS:UnbindFromRenderStep(name) end)
            Connections[name] = nil
        end

        local paused = false
        local accumulated = 0

        vgs.RunS:BindToRenderStep(name, priority, function(dt)
            if paused then return end

            if fpsLimit then
                accumulated = accumulated + dt

                local limit
                if type(fpsLimit) == "number" then
                    limit = fpsLimit
                elseif type(fpsLimit) == "table" then
                    limit = fpsLimit.ref and fpsLimit.ref[fpsLimit.key] or fpsLimit
                end

                local interval = 1 / limit
                if accumulated < interval then return end
                accumulated = accumulated % interval
            end

            cback(dt)
        end)

        Connections[name] = {
            inst = inst,
            eventType = "BindToRenderStep",
            _cbacks = {{func = cback, once = false, counter = 0}},
            _paused = false,
            _setPaused = function(state) paused = state end,
            Disconnect = function(self)
                pcall(function() vgs.RunS:UnbindFromRenderStep(name) end)
                Connections[name] = nil
            end
        }

        return Connections[name]
    end

    local prop = nil

    if not event then
        local fstr = gfstr(cback)
        name = (once and not name) and ("once_" .. tick())
            or stgs[2] or (tostring(inst) .. "_Destroying_" .. fstr)
        if Connections[name] then Connections[name] = nil end
        local conn = inst.Destroying:Connect(cback)
        Connections[name] = {
            connection = conn, inst = inst, eventType = "Destroying",
            _cbacks = {{func = cback, once = once, counter = 0, ttle = ttle}},
            _funcString = fstr, _paused = false,
            Disconnect = function(self)
                if self.connection then
                    pcall(self.connection.Disconnect, self.connection)
                    self.connection = nil
                    Connections[name] = nil
                end
            end
        }
        return Connections[name]
    end

    if event == "PropertyChanged" and #stgs >= 2 then
        prop  = stgs[2]
        name  = stgs[3]
    else
        name = stgs[2]
    end

    local fstr = gfstr(cback)

    if not name then
        if once then
            name = "once_" .. tick()
        else
            name = tostring(inst) .. "_" .. tostring(event)
            if prop then name = name .. "_" .. prop end
            name = name .. "_" .. fstr
        end
    end

    local existing = Connections[name]
    if existing then
        if existing._funcString ~= fstr then name = name .. "_" .. tick()
        else Connections[name] = nil end
    end

    local function rcbs(...)
        local connData = Connections[name]
        if not connData or connData._paused then return end

        local cbacks = connData._cbacks
        local clen = #cbacks
        local toRemove = nil

        for i = 1, clen do
            local cb = cbacks[i]
            local ok = true
            if cb.ttle then
                cb.counter = cb.counter + 1
                local tv = type(cb.ttle) == "table"
                    and (cb.ttle.ref and cb.ttle.ref[cb.ttle.key] or cb.ttle)
                    or cb.ttle
                if cb.counter < tv then ok = false else cb.counter = 0 end
            end
            if ok then
                task.spawn(cb.func, ...)
                if cb.once then
                    if not toRemove then toRemove = {} end
                    toRemove[#toRemove+1] = i
                end
            end
        end

        if toRemove then
            for i = #toRemove, 1, -1 do
                table.remove(cbacks, toRemove[i])
            end
        end

        if once then
            task.defer(function()
                local c = Connections[name]
                if c then pcall(c.Disconnect, c) end
            end)
        end
    end

    local connection
    local ok = pcall(function()
        if event == "PropertyChanged" then
            connection = inst:GetPropertyChangedSignal(prop):Connect(rcbs)
        else
            local evt = inst[event]
            if evt and typeof(evt) == "RBXScriptSignal" then
                connection = evt:Connect(rcbs)
            end
        end
    end)

    if not ok then return end

    task.spawn(function()
        inst.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
                connection = nil
                Connections[name] = nil
            end
        end)
    end)

    Connections[name] = {
        connection = connection, inst = inst, eventType = event, propName = prop,
        _cbacks = {{func = cback, once = once, counter = 0, ttle = ttle}},
        _funcString = fstr, _paused = false, ttle = ttle,
        Disconnect = function(self)
            if self.connection then
                pcall(self.connection.Disconnect, self.connection)
                self.connection = nil
                Connections[name] = nil
            end
        end
    }

    return Connections[name]
end

UModule.UI = {}

local UI = UModule.UI

UI.Config = {
    Theme = {
        Background = Color3.fromRGB(18, 18, 22),
        Sidebar = Color3.fromRGB(14, 14, 18),
        Surface = Color3.fromRGB(28, 28, 34),
        SurfaceHover = Color3.fromRGB(38, 38, 46),
        SurfaceActive = Color3.fromRGB(48, 48, 58),
        Border = Color3.fromRGB(40, 40, 48),
        Text = Color3.fromRGB(220, 220, 230),
        TextDim = Color3.fromRGB(160, 160, 175),
        TextBright = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 262),
        AccentDim = Color3.fromRGB(68, 81, 202),
        Green = Color3.fromRGB(67, 181, 129),
        Red = Color3.fromRGB(242, 78, 78),
        Yellow = Color3.fromRGB(250, 200, 70)
    },
    Font = Enum.Font.Gotham,
    FontSize = {
        Small = 12,
        Medium = 14,
        Large = 16,
        Title = 20
    },
    Corner = {
        Small = 4,
        Medium = 8,
        Large = 12
    },
    Padding = {
        Tiny = 4,
        Small = 8,
        Medium = 12,
        Large = 16,
        XL = 24
    },
    Animation = {
        Duration = 0.15,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    }
}

local function tween(obj, props, duration)
    duration = duration or UI.Config.
