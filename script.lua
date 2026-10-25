-- ============================================================
-- DeepHub Key System Loader
-- ============================================================
local API_URL = "https://deepkeys.zhudrovichvlad.workers.dev"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

local function checkKeyFromFile()
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile("DeepHub_key.txt") then
            local ok, data = pcall(readfile, "DeepHub_key.txt")
            if ok and data then return data:gsub("%s+", "") end
        end
    end
    return nil
end

local function saveKeyToFile(key)
    if type(writefile) == "function" then
        pcall(writefile, "DeepHub_key.txt", key)
    end
end

local function verifyKey(key)
    print("Проверка ключа...")
    local url = API_URL .. "/check?key=" .. game:GetService("HttpService"):UrlEncode(key) .. "&hwid=" .. HWID
    
    local ok, response
    if request then
        ok, response = pcall(function() 
            return request({ Url = url, Method = "GET", Headers = {["Accept"] = "application/json"} }).Body 
        end)
    elseif syn and syn.request then
        ok, response = pcall(function() 
            return syn.request({ Url = url, Method = "GET", Headers = {["Accept"] = "application/json"} }).Body 
        end)
    else
        ok, response = pcall(function() return game:GetService("HttpService"):GetAsync(url) end)
    end

    if not ok then 
        print("Ошибка запроса: " .. tostring(response))
        return false, "network_error" 
    end
    
    local decodeOk, data = pcall(function() return game:GetService("HttpService"):JSONDecode(response) end)
    if not decodeOk then 
        return false, "invalid_response" 
    end
    
    if data.valid then return true else return false, data.reason or "invalid_key" end
end

local function showKeyUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DeepHubKeyUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    local parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then parent = cg end
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 210)
    frame.Position = UDim2.new(0.5, -160, 0.5, -105)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Введите ключ"
    title.TextColor3 = Color3.fromRGB(200, 200, 210)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local txtBox = Instance.new("TextBox")
    txtBox.Size = UDim2.new(1, -40, 0, 36)
    txtBox.Position = UDim2.new(0, 20, 0, 45)
    txtBox.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    txtBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    txtBox.PlaceholderText = "DEEP-XXXX-XXXX"
    txtBox.Font = Enum.Font.Gotham
    txtBox.TextSize = 14
    txtBox.BorderSizePixel = 0
    txtBox.Parent = frame
    Instance.new("UICorner", txtBox).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 85)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- Кнопка "Получить ключ"
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, -40, 0, 34)
    getKeyBtn.Position = UDim2.new(0, 20, 0, 110)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Text = "Получить ключ"
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Parent = frame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)

    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://loot-link.com/s?MwbhJZ1m") end)
        pcall(function() 
            if request then
                request({Url = "https://loot-link.com/s?MwbhJZ1m", Method = "GET"})
            elseif syn and syn.request then
                syn.request({Url = "https://loot-link.com/s?MwbhJZ1m", Method = "GET"})
            else
                game:GetService("GuiService"):OpenBrowserWindow("https://loot-link.com/s?MwbhJZ1m")
            end
        end)
        getKeyBtn.Text = "Ссылка скопирована / открыта"
        task.wait(2)
        getKeyBtn.Text = "Получить ключ"
    end)

    -- Кнопка "Проверить"
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 34)
    btn.Position = UDim2.new(0, 20, 1, -50)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "Проверить"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        local key = txtBox.Text:gsub("%s+", "")
        if key == "" then return end
        
        btn.Text = "Загрузка..."
        status.Text = ""
        
        task.spawn(function()
            local valid, reason = verifyKey(key)
            if valid then
                saveKeyToFile(key) -- Сохраняем ключ в файл
                status.TextColor3 = Color3.fromRGB(0, 200, 100)
                status.Text = "Ключ верный. Загрузка..."
                task.wait(1)
                gui:Destroy()
            else
                btn.Text = "Проверить"
                status.TextColor3 = Color3.fromRGB(255, 80, 80)
                if reason == "network_error" then
                    status.Text = "Ошибка сети."
                elseif reason == "not_found" then
                    status.Text = "Ключ не найден."
                elseif reason == "hwid_mismatch" then
                    status.Text = "Ключ привязан к другому ПК."
                else
                    status.Text = "Ошибка: " .. tostring(reason)
                end
            end
        end)
    end)
    
    -- Блокируем скрипт, пока окно открыто
    repeat task.wait() until not gui.Parent
end

-- Проверка ключа при запуске
local savedKey = checkKeyFromFile()
local needUI = true

if savedKey and savedKey ~= "" then
    local ok, valid = pcall(verifyKey, savedKey)
    if ok and valid then
        print("Найден сохраненный ключ, пропускаем окно.")
        needUI = false
    end
end

if needUI then
    showKeyUI()
end

print("Ключ принят. Запуск DeepHub...")

-- ============================================================
-- ОСНОВНОЙ СКРИПТ DEEPHUB
-- ============================================================
-- (Здесь должен идти твой код DeepHub, начиная с if getgenv...)
-- ============================================================
-- ОСНОВНОЙ СКРИПТ DEEPHUB
-- ============================================================
if getgenv and getgenv().DeepHubLoaded then
    pcall(function() if getgenv().DeepHubUnload then getgenv().DeepHubUnload() end end)
end
if getgenv then getgenv().DeepHubLoaded = true end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speedEnabled = false
local speedValue = 16
local noclipEnabled = false
local espEnabled = false
local chamsEnabled = false
local flyEnabled = false
local flySpeed = 50
local fullbrightEnabled = false
local antiAfkEnabled = false
local npcEspEnabled = false
local itemsEspEnabled = false
local godModeEnabled = false
local hudEnabled = true
local fpsLimit = 999

-- (Здесь идет остальной код из твоего файла блокнота...
--  Просто скопируй его сюда, начиная с local conns = {} до конца)
-- ============================================================
-- ОСНОВНОЙ СКРИПТ DEEPHUB (начинается ниже)
-- ============================================================
-- DeepHub (rev + i18n + HUD + FPS cap + persistence)
-- ============================================================
if getgenv and getgenv().DeepHubLoaded then
    pcall(function() if getgenv().DeepHubUnload then getgenv().DeepHubUnload() end end)
end
if getgenv then getgenv().DeepHubLoaded = true end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- == PERSISTENCE ==
-- ============================================================
local CONFIG_FILE = "DeepHub_config.json"
local function fileRead(name)
    if type(readfile) ~= "function" then return nil end
    local ok, data = pcall(readfile, name)
    if ok then return data end
    return nil
end
local function fileWrite(name, data)
    if type(writefile) ~= "function" then return false end
    return pcall(writefile, name, data)
end
local function isFileExists(name)
    if type(isfile) ~= "function" then return false end
    local ok, res = pcall(isfile, name)
    return ok and res
end

local function jsonEncode(tbl)
    local function esc(s)
        s = tostring(s)
        s = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
        return s
    end
    local function enc(v)
        local tv = type(v)
        if tv == "table" then
            local isArr = #v > 0
            if isArr then
                local parts = {}
                for _, item in ipairs(v) do table.insert(parts, enc(item)) end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                local parts = {}
                for k, item in pairs(v) do
                    table.insert(parts, '"' .. esc(k) .. '":' .. enc(item))
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        elseif tv == "string" then
            return '"' .. esc(v) .. '"'
        elseif tv == "number" then
            return tostring(v)
        elseif tv == "boolean" then
            return tostring(v)
        else
            return "null"
        end
    end
    return enc(tbl)
end

local function jsonDecode(str)
    local pos = 1
    local function skipWs()
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == " " or c == "\n" or c == "\r" or c == "\t" then pos = pos + 1 else break end
        end
    end
    local parseValue
    local function parseString()
        pos = pos + 1
        local out = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '"' then pos = pos + 1 return table.concat(out) end
            if c == "\\" then
                pos = pos + 1
                local n = str:sub(pos, pos)
                if n == "n" then table.insert(out, "\n")
                elseif n == "t" then table.insert(out, "\t")
                elseif n == "r" then table.insert(out, "\r")
                elseif n == '"' then table.insert(out, '"')
                elseif n == "\\" then table.insert(out, "\\")
                else table.insert(out, n) end
                pos = pos + 1
            else
                table.insert(out, c); pos = pos + 1
            end
        end
        return table.concat(out)
    end
    local function parseNumber()
        local start = pos
        while pos <= #str and str:sub(pos, pos):match("[%d%.%-eE+]") do pos = pos + 1 end
        return tonumber(str:sub(start, pos - 1))
    end
    function parseValue()
        skipWs()
        local c = str:sub(pos, pos)
        if c == "{" then
            pos = pos + 1
            local obj = {}
            skipWs()
            if str:sub(pos, pos) == "}" then pos = pos + 1 return obj end
            while pos <= #str do
                skipWs()
                if str:sub(pos, pos) ~= '"' then break end
                local key = parseString()
                skipWs()
                if str:sub(pos, pos) == ":" then pos = pos + 1 end
                obj[key] = parseValue()
                skipWs()
                if str:sub(pos, pos) == "," then pos = pos + 1
                elseif str:sub(pos, pos) == "}" then pos = pos + 1 break end
            end
            return obj
        elseif c == "[" then
            pos = pos + 1
            local arr = {}
            skipWs()
            if str:sub(pos, pos) == "]" then pos = pos + 1 return arr end
            while pos <= #str do
                table.insert(arr, parseValue())
                skipWs()
                if str:sub(pos, pos) == "," then pos = pos + 1
                elseif str:sub(pos, pos) == "]" then pos = pos + 1 break end
            end
            return arr
        elseif c == '"' then
            return parseString()
        elseif c == "t" and str:sub(pos, pos + 3) == "true" then pos = pos + 4 return true
        elseif c == "f" and str:sub(pos, pos + 4) == "false" then pos = pos + 5 return false
        elseif c == "n" and str:sub(pos, pos + 3) == "null" then pos = pos + 4 return nil
        else
            return parseNumber()
        end
    end
    local ok, res = pcall(parseValue)
    if ok then return res end
    return nil
end

-- ============================================================
-- == I18N ==
-- ============================================================
local LANG = "en"
local FLAG = { ru = "🇷🇺", de = "🇩🇪", en = "🇬🇧" }
local STRINGS = {
    en = {
        menu = "Menu", character = "Character", misc = "Misc", settings = "Settings",
        movement = "Movement", survival = "Survival", visual = "Visual",
        flySpeed = "Fly Speed", antiafk = "Anti-AFK", npcesp = "NPC ESP",
        injector = "Injector", usedInjector = "Used injector: ",
        supported = "Supported injectors", supportedList = "Solana, Xeno, Real, Volt and more another!",
        version = "Script version", versionVal = "Beta 0.10",
        donate = "Donate for more updates", discord = "Join to Discord",
        lang = "Language", hud = "HUD (watermark, FPS, ping)", fpslimit = "FPS Limit",
        unloadTitle = "Confirm", unloadText = "Are you sure you want to unload the script? You will have to run it again.",
        yes = "Yes", no = "No", godWarnTitle = "God Mode", godWarnText = "God Mode does not work in this place. Start anyway?",
        copied = "Copied: ", on = "ON", off = "OFF",
    },
    ru = {
        menu = "Меню", character = "Персонаж", misc = "Разное", settings = "Настройки",
        movement = "Движение", survival = "Выживание", visual = "Визуал",
        flySpeed = "Скорость полёта", antiafk = "Анти-АФК", npcesp = "ESP NPC",
        injector = "Инжектор", usedInjector = "Используемый инжектор: ",
        supported = "Поддерживаемые инжекторы", supportedList = "Solana, Xeno, Real, Volt and more another!",
        version = "Версия скрипта", versionVal = "Beta 0.10",
        donate = "Donate for more updates", discord = "Join to Discord",
        lang = "Язык", hud = "HUD (watermark, FPS, пинг)", fpslimit = "Лимит FPS",
        unloadTitle = "Подтверждение", unloadText = "Вы уверены, что хотите выгрузить скрипт? Вам придётся запускать его ещё раз.",
        yes = "Да", no = "Нет", godWarnTitle = "God Mode", godWarnText = "God Mode не работает в этом плейсе, запустить?",
        copied = "Скопировано: ", on = "ВКЛ", off = "ВЫКЛ",
    },
    de = {
        menu = "Menü", character = "Charakter", misc = "Sonstiges", settings = "Einstellungen",
        movement = "Bewegung", survival = "Überleben", visual = "Visuell",
        flySpeed = "Fluggeschwindigkeit", antiafk = "Anti-AFK", npcesp = "NPC ESP",
        injector = "Injector", usedInjector = "Verwendeter Injector: ",
        supported = "Unterstützte Injectoren", supportedList = "Solana, Xeno, Real, Volt and more another!",
        version = "Skriptversion", versionVal = "Beta 0.10",
        donate = "Donate for more updates", discord = "Join to Discord",
        lang = "Sprache", hud = "HUD (Watermark, FPS, Ping)", fpslimit = "FPS-Limit",
        unloadTitle = "Bestätigung", unloadText = "Möchten Sie das Skript wirklich entladen? Sie müssen es erneut starten.",
        yes = "Ja", no = "Nein", godWarnTitle = "God Mode", godWarnText = "God Mode funktioniert in diesem Place nicht. Starten?",
        copied = "Kopiert: ", on = "AN", off = "AUS",
    },
}
local function T(key)
    local t = STRINGS[LANG] or STRINGS.en
    return t[key] or STRINGS.en[key] or key
end

-- ============================================================
-- == STATE ==
-- ============================================================
local speedEnabled = false
local speedValue = 16
local noclipEnabled = false
local espEnabled = false
local chamsEnabled = false
local flyEnabled = false
local flySpeed = 50
local fullbrightEnabled = false
local antiAfkEnabled = false
local npcEspEnabled = false
local itemsEspEnabled = false
local godModeEnabled = false
local hudEnabled = true
local fpsLimit = 999

local conns = {}
local function track(conn)
    table.insert(conns, conn)
    return conn
end
local function untrackAll()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    table.clear(conns)
end

local DrawingAvailable = (typeof(Drawing) == "table" and type(Drawing.new) == "function")
local function safeDrawing(kind)
    if not DrawingAvailable then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if ok and obj then return obj end
    return nil
end

-- ============================================================
-- == CONFIG LOAD ==
-- ============================================================
local function loadConfig()
    if not isFileExists(CONFIG_FILE) then return end
    local raw = fileRead(CONFIG_FILE)
    if not raw or raw == "" then return end
    local data = jsonDecode(raw)
    if type(data) ~= "table" then return end
    if type(data.lang) == "string" and STRINGS[data.lang] then LANG = data.lang end
    if type(data.hudEnabled) == "boolean" then hudEnabled = data.hudEnabled end
    if type(data.fpsLimit) == "number" then fpsLimit = data.fpsLimit end
    if type(data.speedValue) == "number" then speedValue = data.speedValue end
    if type(data.flySpeed) == "number" then flySpeed = data.flySpeed end
    if type(data.speedEnabled) == "boolean" then speedEnabled = data.speedEnabled end
    if type(data.flyEnabled) == "boolean" then flyEnabled = data.flyEnabled end
    if type(data.noclipEnabled) == "boolean" then noclipEnabled = data.noclipEnabled end
    if type(data.espEnabled) == "boolean" then espEnabled = data.espEnabled end
    if type(data.chamsEnabled) == "boolean" then chamsEnabled = data.chamsEnabled end
    if type(data.npcEspEnabled) == "boolean" then npcEspEnabled = data.npcEspEnabled end
    if type(data.itemsEspEnabled) == "boolean" then itemsEspEnabled = data.itemsEspEnabled end
    if type(data.fullbrightEnabled) == "boolean" then fullbrightEnabled = data.fullbrightEnabled end
    if type(data.antiAfkEnabled) == "boolean" then antiAfkEnabled = data.antiAfkEnabled end
    if type(data.godModeEnabled) == "boolean" then godModeEnabled = data.godModeEnabled end
end
local function saveConfig()
    local data = {
        lang = LANG, hudEnabled = hudEnabled, fpsLimit = fpsLimit,
        speedValue = speedValue, flySpeed = flySpeed,
        speedEnabled = speedEnabled, flyEnabled = flyEnabled, noclipEnabled = noclipEnabled,
        espEnabled = espEnabled, chamsEnabled = chamsEnabled, npcEspEnabled = npcEspEnabled,
        itemsEspEnabled = itemsEspEnabled, fullbrightEnabled = fullbrightEnabled,
        antiAfkEnabled = antiAfkEnabled, godModeEnabled = godModeEnabled,
    }
    fileWrite(CONFIG_FILE, jsonEncode(data))
end
loadConfig()

-- ============================================================
-- == GOD MODE ==
-- ============================================================
local godHealthConn = nil
local godDiedConn = nil
local godHooksInstalled = false
local godOldIndex = nil
local godOldNamecall = nil

local function detectGodApi()
    return type(getrawmetatable) == "function"
        and type(setreadonly) == "function"
        and type(newcclosure) == "function"
        and type(checkcaller) == "function"
end

local function installGodHooks()
    if godHooksInstalled then return true end
    if not detectGodApi() then return false end
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return false end
    godOldIndex = mt.__index
    godOldNamecall = mt.__namecall
    if not godOldIndex then return false end
    local ok2 = pcall(function()
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if godModeEnabled and not checkcaller() and (key == "Health" or key == "MaxHealth") then
                local okc, class = pcall(function() return godOldIndex(self, "ClassName") end)
                if okc and class == "Humanoid" then
                    local okp, parent = pcall(function() return godOldIndex(self, "Parent") end)
                    if okp and parent and LP.Character and parent == LP.Character then
                        return 100
                    end
                end
            end
            return godOldIndex(self, key)
        end)
        setreadonly(mt, true)
    end)
    if ok2 then godHooksInstalled = true return true end
    return false
end

local function uninstallGodHooks()
    if not godHooksInstalled then return end
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        setreadonly(mt, false)
        if godOldIndex and mt.__index == godOldIndex then mt.__index = godOldIndex end
        if godOldNamecall and mt.__namecall == godOldNamecall then mt.__namecall = godOldNamecall end
        setreadonly(mt, true)
    end)
    godHooksInstalled = false
end

local function applyGodHealth(char)
    if not char or not godModeEnabled then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if godHealthConn then godHealthConn:Disconnect() godHealthConn = nil end
    if godDiedConn then godDiedConn:Disconnect() godDiedConn = nil end
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)
    godHealthConn = hum.HealthChanged:Connect(function()
        if godModeEnabled and hum and hum.Parent and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
    godDiedConn = hum.Died:Connect(function()
        if godModeEnabled then
            task.wait(0.05)
            if hum and hum.Parent then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end)
end

local function testGodModeWorking()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if not detectGodApi() then return false end
    local wasGod = godModeEnabled
    godModeEnabled = true
    local okInstall = installGodHooks()
    local result = false
    if okInstall then
        local oldHealth = hum.Health
        pcall(function() hum.Health = oldHealth - 1 end)
        task.wait(0.05)
        result = (hum.Health >= oldHealth)
        pcall(function() hum.Health = oldHealth end)
    end
    if not wasGod then
        godModeEnabled = false
        uninstallGodHooks()
    end
    return result and okInstall
end

local function setGodMode(state, force)
    if state then
        local working = testGodModeWorking()
        if not working and not force then
            return false
        end
        godModeEnabled = true
        installGodHooks()
        local char = LP.Character
        if char then applyGodHealth(char) end
        saveConfig()
        return true
    else
        godModeEnabled = false
        uninstallGodHooks()
        if godHealthConn then godHealthConn:Disconnect() godHealthConn = nil end
        if godDiedConn then godDiedConn:Disconnect() godDiedConn = nil end
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.MaxHealth = 100
                    if hum.Health > 100 then hum.Health = 100 end
                    hum.BreakJointsOnDeath = true
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                end)
            end
        end
        saveConfig()
        return true
    end
end

-- ============================================================
-- == ANTI-AFK ==
-- ============================================================
local antiAfkConnection = nil
local antiAfkThread = nil
local function doAntiAfkClick()
    local vu = game:GetService("VirtualUser")
    if not vu then return end
    pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0)) end)
end
local function stopAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() antiAfkConnection = nil end
    if antiAfkThread then task.cancel(antiAfkThread) antiAfkThread = nil end
end
local function startAntiAfk()
    stopAntiAfk()
    antiAfkConnection = LP.Idled:Connect(function() if antiAfkEnabled then doAntiAfkClick() end end)
    antiAfkThread = task.spawn(function()
        while antiAfkEnabled do task.wait(55) if antiAfkEnabled then doAntiAfkClick() end end
    end)
end
local function setAntiAfk(state) antiAfkEnabled = state; if state then startAntiAfk() else stopAntiAfk() end; saveConfig() end

-- ============================================================
-- == FULLBRIGHT ==
-- ============================================================
local originalLighting = {}
local fbConnection = nil
local function saveLighting()
    originalLighting = {
        Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, ShadowSoftness = Lighting.ShadowSoftness,
    }
end
local function applyFullbright()
    pcall(function()
        Lighting.Brightness = 2; Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.FogStart = 0; Lighting.FogEnd = 9999999; Lighting.ShadowSoftness = 0
    end)
end
local function restoreLighting()
    pcall(function() for k,v in pairs(originalLighting) do if Lighting[k] ~= nil then Lighting[k] = v end end end)
end
local function setFullbright(state)
    fullbrightEnabled = state
    if state then
        saveLighting(); applyFullbright()
        fbConnection = Lighting.Changed:Connect(function() if fullbrightEnabled then task.defer(applyFullbright) end end)
    else
        if fbConnection then fbConnection:Disconnect() fbConnection = nil end
        restoreLighting()
    end
    saveConfig()
end

-- ============================================================
-- == SPEED ==
-- ============================================================
track(RunService.Heartbeat:Connect(function()
    if not speedEnabled then return end
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= speedValue then hum.WalkSpeed = speedValue end
end))

-- ============================================================
-- == NOCLIP ==
-- ============================================================
local function applyNoclip(state, char)
    char = char or LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = not state end
    end
end
local noclipLastChar = nil
track(RunService.Heartbeat:Connect(function()
    if not noclipEnabled then return end
    local char = LP.Character
    if char and char ~= noclipLastChar then
        noclipLastChar = char
        applyNoclip(true, char)
    end
end))

-- ============================================================
-- == FLY ==
-- ============================================================
local flyConnection = nil; local flyBV = nil; local flyBG = nil
local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end
local function startFly()
    stopFly()
    local char = LP.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge); flyBV.Velocity = Vector3.zero; flyBV.P = 1250; flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); flyBG.P = 9e4; flyBG.D = 500; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    hum.PlatformStand = true
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        if UIS:GetFocusedTextBox() then if flyBV then flyBV.Velocity = Vector3.zero end return end
        local c = LP.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        if not root or not flyBV or not flyBG then return end
        local dir = Vector3.zero; local camCF = camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * flySpeed end
        flyBV.Velocity = dir
        flyBG.CFrame = CFrame.new(root.Position, root.Position + camCF.LookVector)
    end)
end
local function setFly(state) flyEnabled = state; if state then startFly() else stopFly() end; saveConfig() end

-- ============================================================
-- == HELPERS ==
-- ============================================================
local function collectKeyParts(model)
    local parts = {}
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    if hrp then table.insert(parts, hrp) end
    if head then table.insert(parts, head) end
    if #parts == 0 then
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(parts, p) if #parts >= 4 then break end end
        end
    end
    return parts
end

local function boundsFromParts(parts)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local found = false
    for _, part in ipairs(parts) do
        local cf, sz = part.CFrame, part.Size
        for _, sx in ipairs({-1,1}) do for _, sy in ipairs({-1,1}) do for _, sz_ in ipairs({-1,1}) do
            local w = (cf * CFrame.new(sx*sz.X/2, sy*sz.Y/2, sz_*sz.Z/2)).Position
            local sp = camera:WorldToViewportPoint(w)
            if sp.Z > 0 then
                if sp.X<minX then minX=sp.X end; if sp.X>maxX then maxX=sp.X end
                if sp.Y<minY then minY=sp.Y end; if sp.Y>maxY then maxY=sp.Y end
                found = true
            end
        end end end
    end
    if not found then return nil end
    return minX, minY, maxX, maxY
end

-- ============================================================
-- == PLAYER ESP ==
-- ============================================================
local espEntries = {}
local function cleanupESP(plr)
    local e = espEntries[plr]
    if e then
        pcall(function() e.box:Remove() end)
        pcall(function() e.name:Remove() end)
        espEntries[plr] = nil
    end
end
local function ensureESP(plr)
    if plr == LP or espEntries[plr] then return end
    local box = safeDrawing("Square")
    local nm = safeDrawing("Text")
    if not box or not nm then return end
    box.Thickness = 1; box.Color = Color3.fromRGB(255,50,50); box.Filled = false; box.Visible = false
    nm.Size = 13; nm.Center = true; nm.Outline = true; nm.Color = Color3.fromRGB(255,255,255); nm.Visible = false
    espEntries[plr] = {box = box, name = nm}
end
for _, p in ipairs(Players:GetPlayers()) do ensureESP(p) end
track(Players.PlayerAdded:Connect(ensureESP))
track(Players.PlayerRemoving:Connect(cleanupESP))

track(RunService.RenderStepped:Connect(function()
    if not DrawingAvailable then return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP and not espEntries[p] then ensureESP(p) end end
    for plr, e in pairs(espEntries) do
        if not espEnabled then e.box.Visible=false; e.name.Visible=false; continue end
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum and hum.Health > 0 then
            local parts = collectKeyParts(char)
            local minX,minY,maxX,maxY = boundsFromParts(parts)
            if minX then
                local w,h = maxX-minX, maxY-minY; if w<4 then w=4 end; if h<4 then h=4 end
                e.box.Size = Vector2.new(w,h); e.box.Position = Vector2.new(minX,minY); e.box.Visible = true
                e.name.Text = plr.Name.." ["..math.floor(hum.Health).."]"
                e.name.Position = Vector2.new((minX+maxX)/2, minY-16); e.name.Visible = true
            else e.box.Visible=false; e.name.Visible=false end
        else e.box.Visible=false; e.name.Visible=false end
    end
end))

-- ============================================================
-- == PLAYER CHAMS ==
-- ============================================================
local chamHighlights = {}
local function removeChams(plr)
    local h = chamHighlights[plr]
    if h then pcall(function() h:Destroy() end) chamHighlights[plr] = nil end
end
local function applyChams(plr)
    if plr == LP or chamHighlights[plr] then return end
    local char = plr.Character; if not char or char:FindFirstChild("__chams") then return end
    local h = Instance.new("Highlight")
    h.Name="__chams"; h.Adornee=char; h.FillColor=Color3.fromRGB(255,60,60); h.FillTransparency=0.5
    h.OutlineColor=Color3.fromRGB(255,0,0); h.OutlineTransparency=0
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char
    chamHighlights[plr]=h
end
local function refreshChams()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then if chamsEnabled then applyChams(plr) else removeChams(plr) end end
    end
end
track(Players.PlayerAdded:Connect(function(plr)
    track(plr.CharacterAdded:Connect(function() task.wait(0.2) if chamsEnabled then applyChams(plr) end end))
    if chamsEnabled then task.wait(0.5) applyChams(plr) end
end))
track(Players.PlayerRemoving:Connect(removeChams))

-- ============================================================
-- == NPC ESP ==
-- ============================================================
local npcEntries = {}
local MAX_NPC_DIST = 800
local NPU = 2
local npcFrameSkip = 0
local npcDiscoveryConn = nil
local npcSpawnThread = nil

local function isPlayerChar(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function ensureNpcEntry(model)
    if npcEntries[model] then return end
    if not model:FindFirstChildOfClass("Humanoid") then return end
    if isPlayerChar(model) then return end
    if not DrawingAvailable then return end
    local box = safeDrawing("Square")
    local nm = safeDrawing("Text")
    if not box or not nm then return end
    box.Thickness = 1; box.Color = Color3.fromRGB(0,200,255); box.Filled = false; box.Visible = false
    nm.Size = 13; nm.Center = true; nm.Outline = true; nm.Color = Color3.fromRGB(120,230,255); nm.Visible = false
    local h = Instance.new("Highlight")
    h.Name = "__npcchams"; h.Adornee = model
    h.FillColor = Color3.fromRGB(0,180,255); h.FillTransparency = 0.5
    h.OutlineColor = Color3.fromRGB(0,200,255); h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Enabled = npcEspEnabled; h.Parent = model
    npcEntries[model] = {box = box, name = nm, highlight = h}
end

local function removeNpcEntry(model)
    local e = npcEntries[model]
    if e then
        pcall(function() e.box:Remove() end)
        pcall(function() e.name:Remove() end)
        pcall(function() e.highlight:Destroy() end)
        npcEntries[model] = nil
    end
end

local function getModelScreenBounds(model)
    local ok, cf, size = pcall(function() return model:GetBoundingBox() end)
    if not ok or not cf then return nil end
    local centerVP = camera:WorldToViewportPoint(cf.Position)
    if centerVP.Z <= 0 then return nil end
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local found = false
    for _, sx in ipairs({-1,1}) do for _, sy in ipairs({-1,1}) do for _, sz_ in ipairs({-1,1}) do
        local w = (cf * CFrame.new(sx*size.X/2, sy*size.Y/2, sz_*size.Z/2)).Position
        local sp = camera:WorldToViewportPoint(w)
        if sp.Z > 0 then
            if sp.X<minX then minX=sp.X end; if sp.X>maxX then maxX=sp.X end
            if sp.Y<minY then minY=sp.Y end; if sp.Y>maxY then maxY=sp.Y end
            found = true
        end
    end end end
    if not found then return nil end
    return minX, minY, maxX, maxY
end

local function startNpcDiscovery()
    if npcDiscoveryConn then npcDiscoveryConn:Disconnect() npcDiscoveryConn = nil end
    if npcSpawnThread then task.cancel(npcSpawnThread) npcSpawnThread = nil end
    npcSpawnThread = task.spawn(function()
        local stack = {workspace}
        local count = 0
        while #stack > 0 do
            if not npcEspEnabled then return end
            local cur = table.remove(stack)
            if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") and not isPlayerChar(cur) then
                ensureNpcEntry(cur)
            end
            for _, child in ipairs(cur:GetChildren()) do table.insert(stack, child) end
            count = count + 1
            if count % 200 == 0 then task.wait() end
        end
    end)
    npcDiscoveryConn = workspace.DescendantAdded:Connect(function(obj)
        if not npcEspEnabled then return end
        if not obj:IsA("Humanoid") then return end
        task.defer(function()
            if not npcEspEnabled then return end
            local model = obj.Parent
            if model and model:IsA("Model") and not isPlayerChar(model) then
                ensureNpcEntry(model)
            end
        end)
    end)
end

local function stopNpcDiscovery()
    if npcDiscoveryConn then npcDiscoveryConn:Disconnect() npcDiscoveryConn = nil end
    if npcSpawnThread then task.cancel(npcSpawnThread) npcSpawnThread = nil end
end

track(task.spawn(function()
    while true do
        task.wait(3)
        for model in pairs(npcEntries) do
            if not model.Parent or not model:FindFirstChildOfClass("Humanoid") then
                removeNpcEntry(model)
            end
        end
    end
end))

track(RunService.RenderStepped:Connect(function()
    if not npcEspEnabled then return end
    npcFrameSkip = npcFrameSkip + 1
    if npcFrameSkip % NPU ~= 0 then return end
    local camPos = camera.CFrame.Position
    for model, e in pairs(npcEntries) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if not hum or hum.Health <= 0 or not model.Parent or not hrp then
            e.box.Visible = false; e.name.Visible = false; continue
        end
        if (hrp.Position - camPos).Magnitude > MAX_NPC_DIST then
            e.box.Visible = false; e.name.Visible = false; continue
        end
        local minX, minY, maxX, maxY = getModelScreenBounds(model)
        if minX then
            local w, h = maxX - minX, maxY - minY
            if w < 4 then w = 4 end; if h < 4 then h = 4 end
            e.box.Size = Vector2.new(w, h); e.box.Position = Vector2.new(minX, minY); e.box.Visible = true
            local npcName = (hum.DisplayName ~= "" and hum.DisplayName) or model.Name
            e.name.Text = npcName .. " [" .. math.floor(hum.Health) .. "]"
            e.name.Position = Vector2.new((minX + maxX) / 2, minY - 16); e.name.Visible = true
        else
            e.box.Visible = false; e.name.Visible = false
        end
    end
end))

-- ============================================================
-- == ITEMS ESP ==
-- ============================================================
local MAX_ITEM_DIST = 1000
local itemEntries = {}
local itemDiscoveryConn = nil
local itemSpawnThread = nil

local function isPlayerOrNpc(owner)
    if not owner then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and (owner == char or owner:IsDescendantOf(char)) then return true end
    end
    local cur = owner
    for _ = 1, 5 do
        if not cur then break end
        if cur:FindFirstChildOfClass("Humanoid") then return true end
        cur = cur.Parent
    end
    return false
end

local function getPromptOwner(prompt)
    local p = prompt.Parent
    if not p then return nil end
    if p:IsA("BasePart") or p:IsA("Model") then return p end
    local gp = p.Parent
    if gp and (gp:IsA("Model") or gp:IsA("BasePart")) then return gp end
    return nil
end

local function removeItemEntry(owner)
    local e = itemEntries[owner]
    if e then
        pcall(function() e.highlight:Destroy() end)
        pcall(function() e.billboard:Destroy() end)
        itemEntries[owner] = nil
    end
end

local function addItemEntry(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local owner = getPromptOwner(prompt)
    if not owner then return end
    if isPlayerOrNpc(owner) then return end
    if itemEntries[owner] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "__itemsesp"; hl.Adornee = owner
    hl.FillColor = Color3.fromRGB(0,255,140); hl.FillTransparency = 0.65
    hl.OutlineColor = Color3.fromRGB(0,255,140); hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = itemsEspEnabled; hl.Parent = owner
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "__itemsespname"; billboard.Adornee = owner
    billboard.Size = UDim2.new(0,200,0,30); billboard.StudsOffset = Vector3.new(0,4,0)
    billboard.AlwaysOnTop = true; billboard.Enabled = itemsEspEnabled; billboard.Parent = owner
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0,255,140); label.TextStrokeTransparency = 0.5
    label.TextSize = 16; label.Font = Enum.Font.GothamBold
    label.Text = (prompt.ObjectText ~= "" and prompt.ObjectText) or (prompt.ActionText ~= "" and prompt.ActionText) or "Item"
    label.Parent = billboard
    itemEntries[owner] = {highlight = hl, billboard = billboard}
end

local function startItemDiscovery()
    if itemDiscoveryConn then itemDiscoveryConn:Disconnect() itemDiscoveryConn = nil end
    if itemSpawnThread then task.cancel(itemSpawnThread) itemSpawnThread = nil end
    itemSpawnThread = task.spawn(function()
        local stack = {workspace}
        local count = 0
        while #stack > 0 do
            if not itemsEspEnabled then return end
            local cur = table.remove(stack)
            if cur:IsA("ProximityPrompt") then addItemEntry(cur) end
            for _, child in ipairs(cur:GetChildren()) do table.insert(stack, child) end
            count = count + 1
            if count % 200 == 0 then task.wait() end
        end
    end)
    itemDiscoveryConn = workspace.DescendantAdded:Connect(function(obj)
        if not itemsEspEnabled then return end
        if obj:IsA("ProximityPrompt") then
            task.defer(function() if itemsEspEnabled then addItemEntry(obj) end end)
        end
    end)
end

local function stopItemDiscovery()
    if itemDiscoveryConn then itemDiscoveryConn:Disconnect() itemDiscoveryConn = nil end
    if itemSpawnThread then task.cancel(itemSpawnThread) itemSpawnThread = nil end
end

track(task.spawn(function()
    while true do
        task.wait(3)
        for owner in pairs(itemEntries) do
            if not owner.Parent or isPlayerOrNpc(owner) then removeItemEntry(owner) end
        end
    end
end))

track(RunService.Heartbeat:Connect(function()
    if not itemsEspEnabled then return end
    local camPos = camera.CFrame.Position
    for owner, e in pairs(itemEntries) do
        local pos
        if owner:IsA("BasePart") then pos = owner.Position
        elseif owner.PrimaryPart then pos = owner.PrimaryPart.Position
        else
            local ok, cf = pcall(function() return owner:GetBoundingBox() end)
            if ok then pos = cf.Position end
        end
        local visible = pos and (pos - camPos).Magnitude <= MAX_ITEM_DIST
        e.highlight.Enabled = visible
        e.billboard.Enabled = visible
    end
end))

-- ============================================================
-- == FPS LIMIT ==
-- ============================================================
local function applyFpsCap(v)
    fpsLimit = v
    if type(setfpscap) == "function" then
        pcall(setfpscap, v)
    end
    saveConfig()
end

-- ============================================================
-- == HUD ==
-- ============================================================
local hudGui = nil
local hudFrame, hudWatermark, hudFps, hudPing = nil, nil, nil, nil
local HUD_W, HUD_H = 200, 66

local function buildHudGui()
    if hudGui then return end
    local ok, err = pcall(function()
        hudGui = Instance.new("ScreenGui")
        hudGui.Name = "DeepHubHUD"
        hudGui.ResetOnSpawn = false
        hudGui.IgnoreGuiInset = true
        hudGui.DisplayOrder = 998
        
        local parent = LP:WaitForChild("PlayerGui")
        local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
        if okCg and cg then parent = cg end
        hudGui.Parent = parent

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, HUD_W, 0, HUD_H)
        frame.Position = UDim2.new(0.5, -100, 1, -HUD_H - 110)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Parent = hudGui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(52, 52, 62); stroke.Thickness = 1

        local wm = Instance.new("TextLabel")
        wm.Size = UDim2.new(1, -12, 0, 22); wm.Position = UDim2.new(0, 6, 0, 4)
        wm.BackgroundTransparency = 1
        wm.Text = "DeepHub | Beta 0.10"
        wm.TextColor3 = Color3.fromRGB(120, 200, 255)
        wm.Font = Enum.Font.GothamBold; wm.TextSize = 13
        wm.TextXAlignment = Enum.TextXAlignment.Left
        wm.Parent = frame

        local fpsLbl = Instance.new("TextLabel")
        fpsLbl.Size = UDim2.new(1, -12, 0, 18); fpsLbl.Position = UDim2.new(0, 6, 0, 26)
        fpsLbl.BackgroundTransparency = 1; fpsLbl.Text = "FPS: 0"
        fpsLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        fpsLbl.Font = Enum.Font.Gotham; fpsLbl.TextSize = 12
        fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
        fpsLbl.Parent = frame

        local pingLbl = Instance.new("TextLabel")
        pingLbl.Size = UDim2.new(1, -12, 0, 18); pingLbl.Position = UDim2.new(0, 6, 0, 44)
        pingLbl.BackgroundTransparency = 1; pingLbl.Text = "Ping: 0 ms"
        pingLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        pingLbl.Font = Enum.Font.Gotham; pingLbl.TextSize = 12
        pingLbl.TextXAlignment = Enum.TextXAlignment.Left
        pingLbl.Parent = frame

        hudFrame = frame; hudWatermark = wm; hudFps = fpsLbl; hudPing = pingLbl
        frame.Visible = hudEnabled

        local drag, dStart, sPos
        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag = true; dStart = inp.Position; sPos = frame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        track(UIS.InputChanged:Connect(function(inp)
            if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - dStart
                frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
            end
        end))
    end)
    if not ok then
        warn("DeepHub HUD failed to load: " .. tostring(err))
    end
end
buildHudGui()

local fpsCounter = 0
local fpsTimer = 0
local currentFps = 0
local pingValue = 0
track(RunService.RenderStepped:Connect(function(dt)
    fpsCounter = fpsCounter + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        currentFps = math.floor(fpsCounter / fpsTimer + 0.5)
        fpsCounter = 0; fpsTimer = 0
    end
    if hudFps and hudPing then
        local ok, ping = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok and ping then pingValue = math.floor(ping) end
        hudFps.Text = "FPS: " .. currentFps
        hudPing.Text = "Ping: " .. pingValue .. " ms"
    end
end))

local function setHudEnabled(state)
    hudEnabled = state
    if hudFrame then hudFrame.Visible = state end
    saveConfig()
end

-- ============================================================
-- == UI ==
-- ============================================================
pcall(function() game:GetService("CoreGui").DeepHub:Destroy() end)
local parentGui
do
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (ok and cg) or LP:WaitForChild("PlayerGui")
end

local COL_BG      = Color3.fromRGB(16,16,20)
local COL_PANEL   = Color3.fromRGB(22,22,28)
local COL_SIDEBAR = Color3.fromRGB(26,26,33)
local COL_ACCENT  = Color3.fromRGB(0,150,90)
local COL_TEXT    = Color3.fromRGB(225,225,232)
local COL_DIM     = Color3.fromRGB(140,140,155)
local COL_STROKE  = Color3.fromRGB(52,52,62)

local WIN_W, WIN_H = 520, 400
local SIDEBAR_W = 130

local gui = Instance.new("ScreenGui")
gui.Name = "DeepHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.DisplayOrder = 999; gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
main.BackgroundColor3 = COL_BG; main.BorderSizePixel = 0
main.Active = true; main.ClipsDescendants = true; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = COL_STROKE; mainStroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = COL_PANEL
title.Text = "  DeepHub"; title.TextColor3 = COL_TEXT
title.Font = Enum.Font.GothamBold; title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left; title.BorderSizePixel = 0; title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30); closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 17
closeBtn.BorderSizePixel = 0; closeBtn.AutoButtonColor = false; closeBtn.ZIndex = 2; closeBtn.Parent = title
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(1, -56, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48); minBtn.Text = "–"
minBtn.TextColor3 = COL_TEXT
minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 17
minBtn.BorderSizePixel = 0; minBtn.AutoButtonColor = false; minBtn.ZIndex = 2; minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -32); sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = COL_SIDEBAR; sidebar.BorderSizePixel = 0; sidebar.Parent = main

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local sidebarPad = Instance.new("UIPadding")
sidebarPad.PaddingTop = UDim.new(0, 8)
sidebarPad.PaddingLeft = UDim.new(0, 8)
sidebarPad.PaddingRight = UDim.new(0, 8)
sidebarPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -SIDEBAR_W, 1, -32)
content.Position = UDim2.new(0, SIDEBAR_W, 0, 32)
content.BackgroundColor3 = COL_BG; content.BorderSizePixel = 0; content.Parent = main

local pages = {}
local TABS = {"menu", "character", "misc", "settings"}

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 4; page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10); pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    pages[name] = page
    return page
end
for _, name in ipairs(TABS) do makePage(name) end

local tabButtons = {}
local activeTab = nil
local function selectTab(name)
    activeTab = name
    for tabName, page in pairs(pages) do page.Visible = (tabName == name) end
    for tabName, btn in pairs(tabButtons) do
        if tabName == name then
            btn.BackgroundColor3 = COL_ACCENT
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
            btn.TextColor3 = COL_DIM
        end
    end
end

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    btn.TextColor3 = COL_DIM
    btn.Text = T(name)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.LayoutOrder = i; btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    tabButtons[name] = btn
end
selectTab("character")

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        sidebar.Visible = false; content.Visible = false
        main.Size = UDim2.new(0, WIN_W, 0, 32); minBtn.Text = "+"
    else
        sidebar.Visible = true; content.Visible = true
        main.Size = UDim2.new(0, WIN_W, 0, WIN_H); minBtn.Text = "–"
    end
end)

local dragging, dragStart, startPos
track(title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mx, my = input.Position.X, input.Position.Y
        local cb, mb = closeBtn.AbsolutePosition, minBtn.AbsolutePosition
        local cs, ms = closeBtn.AbsoluteSize, minBtn.AbsoluteSize
        if (mx >= cb.X and mx <= cb.X + cs.X and my >= cb.Y and my <= cb.Y + cs.Y) then return end
        if (mx >= mb.X and mx <= mb.X + ms.X and my >= mb.Y and my <= mb.Y + ms.Y) then return end
        dragging = true; dragStart = input.Position; startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end))
track(UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- == WIDGETS ==
local function makeLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(120, 200, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order; lbl.Parent = parent
    return lbl
end

local function makeInfoBox(parent, lines, order)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 22 * #lines + 12)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    box.BorderSizePixel = 0; box.LayoutOrder = order; box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", box)
    pad.PaddingTop = UDim.new(0, 6); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = box
    local layout = Instance.new("UIListLayout", box)
    layout.Padding = UDim.new(0, 0); layout.SortOrder = Enum.SortOrder.LayoutOrder
    for i, line in ipairs(lines) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22); lbl.BackgroundTransparency = 1
        lbl.Text = line; lbl.TextColor3 = COL_TEXT
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.LayoutOrder = i; lbl.Parent = box
    end
    return box
end

local FN = {
    speed = "Speed", fly = "Fly", godmode = "God Mode", noclip = "Noclip",
    chams = "Chams", fullbright = "FullBright", itemsesp = "ESP Items",
}

local function makeToggle(parent, label, order, initial, callback, fixedLabel)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = initial and COL_ACCENT or Color3.fromRGB(36, 36, 44)
    btn.TextColor3 = COL_TEXT
    btn.Text = label .. ": " .. (initial and "ON" or "OFF")
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.LayoutOrder = order; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 10)
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and COL_ACCENT or Color3.fromRGB(36, 36, 44)
        callback(state)
    end)
    return btn
end

local function makeSlider(parent, label, minV, maxV, defaultV, order, onChange)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 24)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    bg.BorderSizePixel = 0; bg.LayoutOrder = order; bg.Parent = parent
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultV-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = COL_ACCENT; fill.BorderSizePixel = 0; fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 1, 0); lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. defaultV
    lbl.TextColor3 = COL_TEXT; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = bg
    local value = defaultV
    local function update()
        local t = math.clamp((value - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(t, 0, 1, 0)
        lbl.Text = label .. ": " .. math.floor(value)
    end
    update()
    local draggingS = false
    local function input(inp)
        local rel = math.clamp((inp.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        value = math.floor(minV + rel * (maxV - minV) + 0.5); update(); onChange(value)
    end
    track(bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            draggingS = true; input(inp)
        end
    end))
    track(UIS.InputChanged:Connect(function(inp)
        if draggingS and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then input(inp) end
    end))
    track(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then draggingS = false end
    end))
    return bg
end

local function makeDropdown(parent, label, options, defaultIdx, order, onChange)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    btn.TextColor3 = COL_TEXT
    btn.Text = label .. ": " .. options[defaultIdx]
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.LayoutOrder = order; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 10)
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 34 * #options + 4)
    list.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    list.BorderSizePixel = 0; list.LayoutOrder = order + 1; list.Visible = false
    list.Parent = parent
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 2); listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local listPad = Instance.new("UIPadding", list)
    listPad.PaddingTop = UDim.new(0, 2); listPad.PaddingLeft = UDim.new(0, 4); listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = list
    local currentIdx = defaultIdx
    local function select(idx)
        currentIdx = idx
        btn.Text = label .. ": " .. options[idx]
        list.Visible = false
        onChange(idx, options[idx])
    end
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 32)
        optBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
        optBtn.TextColor3 = COL_TEXT
        optBtn.Text = opt; optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 12
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.BorderSizePixel = 0; optBtn.AutoButtonColor = false
        optBtn.LayoutOrder = i; optBtn.Parent = list
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
        local opad = Instance.new("UIPadding", optBtn); opad.PaddingLeft = UDim.new(0, 8)
        optBtn.MouseButton1Click:Connect(function() select(i) end)
    end
    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    return btn, list
end

-- ============================================================
-- == PAGE: CHARACTER ==
-- ============================================================
do
    local p = pages["character"]
    makeLabel(p, T("movement"), 1)
    makeToggle(p, FN.speed, 2, speedEnabled, function(s) speedEnabled = s; saveConfig() end, true)
    -- Обновлено: максимальное значение слайдера теперь 300
    makeSlider(p, FN.speed, 16, 300, speedValue, 3, function(v)
        speedValue = v; saveConfig()
        if speedEnabled then
            local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speedValue end
        end
    end)
    makeToggle(p, FN.fly, 4, flyEnabled, function(s) setFly(s) end, true)
    makeSlider(p, T("flySpeed"), 10, 300, flySpeed, 5, function(v) flySpeed = v; saveConfig() end)
    makeToggle(p, FN.noclip, 6, noclipEnabled, function(s)
        noclipEnabled = s; saveConfig()
        if s then applyNoclip(true) else applyNoclip(false) end
    end, true)
    makeLabel(p, T("survival"), 7)
    makeToggle(p, FN.godmode, 8, godModeEnabled, function(s)
        local ok = setGodMode(s)
        if not ok and s then
            local dialog = Instance.new("ScreenGui")
            dialog.Name = "DeepHubGodWarn"; dialog.ResetOnSpawn = false
            dialog.DisplayOrder = 1000; dialog.Parent = parentGui
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 340, 0, 140)
            box.Position = UDim2.new(0.5, -170, 0.5, -70)
            box.BackgroundColor3 = COL_PANEL; box.BorderSizePixel = 0; box.Parent = dialog
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
            local ttl = Instance.new("TextLabel")
            ttl.Size = UDim2.new(1, -20, 0, 28); ttl.Position = UDim2.new(0, 10, 0, 8)
            ttl.BackgroundTransparency = 1; ttl.Text = T("godWarnTitle")
            ttl.TextColor3 = COL_TEXT; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 14
            ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = box
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -20, 0, 50); txt.Position = UDim2.new(0, 10, 0, 40)
            txt.BackgroundTransparency = 1; txt.Text = T("godWarnText")
            txt.TextColor3 = COL_DIM; txt.Font = Enum.Font.Gotham; txt.TextSize = 12
            txt.TextWrapped = true; txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextYAlignment = Enum.TextYAlignment.Top; txt.Parent = box
            local yes = Instance.new("TextButton")
            yes.Size = UDim2.new(0, 140, 0, 30); yes.Position = UDim2.new(0, 10, 1, -40)
            yes.BackgroundColor3 = COL_ACCENT; yes.Text = T("yes"); yes.TextColor3 = COL_TEXT
            yes.Font = Enum.Font.GothamSemibold; yes.TextSize = 12; yes.BorderSizePixel = 0; yes.Parent = box
            Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 6)
            yes.MouseButton1Click:Connect(function()
                setGodMode(true, true)
                dialog:Destroy()
            end)
            local no = Instance.new("TextButton")
            no.Size = UDim2.new(0, 140, 0, 30); no.Position = UDim2.new(1, -150, 1, -40)
            no.BackgroundColor3 = Color3.fromRGB(60,30,30); no.Text = T("no"); no.TextColor3 = COL_TEXT
            no.Font = Enum.Font.GothamSemibold; no.TextSize = 12; no.BorderSizePixel = 0; no.Parent = box
            Instance.new("UICorner", no).CornerRadius = UDim.new(0, 6)
            no.MouseButton1Click:Connect(function() dialog:Destroy() end)
        end
    end, true)
    makeToggle(p, T("antiafk"), 9, antiAfkEnabled, function(s) setAntiAfk(s) end)
end

-- ============================================================
-- == PAGE: MISC ==
-- ============================================================
do
    local p = pages["misc"]
    makeLabel(p, T("visual"), 1)
    makeToggle(p, "ESP", 2, espEnabled, function(s) espEnabled = s; saveConfig() end, true)
    makeToggle(p, FN.chams, 3, chamsEnabled, function(s) chamsEnabled = s; refreshChams(); saveConfig() end, true)
    makeToggle(p, T("npcesp"), 4, npcEspEnabled, function(s)
        npcEspEnabled = s; saveConfig()
        if s then
            startNpcDiscovery()
            for _, e in pairs(npcEntries) do if e.highlight then e.highlight.Enabled = true end end
        else
            stopNpcDiscovery()
            for _, e in pairs(npcEntries) do
                if e.highlight then e.highlight.Enabled = false end
                e.box.Visible = false; e.name.Visible = false
            end
        end
    end)
    makeToggle(p, FN.itemsesp, 5, itemsEspEnabled, function(s)
        itemsEspEnabled = s; saveConfig()
        if s then
            startItemDiscovery()
            for _, e in pairs(itemEntries) do e.highlight.Enabled = true; e.billboard.Enabled = true end
        else
            stopItemDiscovery()
            for _, e in pairs(itemEntries) do e.highlight.Enabled = false; e.billboard.Enabled = false end
        end
    end, true)
    makeToggle(p, FN.fullbright, 6, fullbrightEnabled, function(s) setFullbright(s) end, true)
end

-- ============================================================
-- == PAGE: MENU ==
-- ============================================================
do
    local p = pages["menu"]
    local injectorName = "Universal (не определён)"
    pcall(function()
        if identifyexecutor then injectorName = identifyexecutor()
        elseif getexecutorname then injectorName = getexecutorname() end
    end)
    makeLabel(p, T("injector"), 1)
    makeInfoBox(p, { T("usedInjector") .. injectorName }, 2)
    makeLabel(p, T("supported"), 3)
    makeInfoBox(p, { T("supportedList") }, 4)
    makeLabel(p, T("version"), 5)
    makeInfoBox(p, { T("versionVal") }, 6)
    makeLabel(p, T("donate"), 7)
    local donateBtn = Instance.new("TextButton")
    donateBtn.Size = UDim2.new(1, 0, 0, 34)
    donateBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    donateBtn.Text = "https://dalink.to/lovewife"
    donateBtn.TextColor3 = Color3.fromRGB(120, 200, 255)
    donateBtn.Font = Enum.Font.GothamSemibold; donateBtn.TextSize = 12
    donateBtn.TextXAlignment = Enum.TextXAlignment.Left
    donateBtn.BorderSizePixel = 0; donateBtn.AutoButtonColor = false
    donateBtn.LayoutOrder = 8; donateBtn.Parent = p
    Instance.new("UICorner", donateBtn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", donateBtn); pad.PaddingLeft = UDim.new(0, 10)
    track(donateBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://dalink.to/lovewife") end)
        donateBtn.Text = T("copied") .. "https://dalink.to/lovewife"
        task.delay(1.5, function()
            if donateBtn and donateBtn.Parent then donateBtn.Text = "https://dalink.to/lovewife" end
        end)
    end))

    makeLabel(p, T("discord"), 9)
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(1, 0, 0, 34)
    discordBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    discordBtn.Text = "https://discord.gg/ZmVsgwGczX"
    discordBtn.TextColor3 = Color3.fromRGB(120, 200, 255)
    discordBtn.Font = Enum.Font.GothamSemibold; discordBtn.TextSize = 12
    discordBtn.TextXAlignment = Enum.TextXAlignment.Left
    discordBtn.BorderSizePixel = 0; discordBtn.AutoButtonColor = false
    discordBtn.LayoutOrder = 10; discordBtn.Parent = p
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 6)
    local pad2 = Instance.new("UIPadding", discordBtn); pad2.PaddingLeft = UDim.new(0, 10)
    track(discordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/ZmVsgwGczX") end)
        discordBtn.Text = T("copied") .. "https://discord.gg/ZmVsgwGczX"
        task.delay(1.5, function()
            if discordBtn and discordBtn.Parent then discordBtn.Text = "https://discord.gg/ZmVsgwGczX" end
        end)
    end))
end

-- ============================================================
-- == PAGE: SETTINGS ==
-- ============================================================
do
    local p = pages["settings"]
    makeLabel(p, T("lang"), 1)
    local langOptions = {
        FLAG.en .. " English", FLAG.de .. " Deutsch", FLAG.ru .. " Русский"
    }
    local langIdx = 1
    if LANG == "de" then langIdx = 2 elseif LANG == "ru" then langIdx = 3 end
    makeDropdown(p, T("lang"), langOptions, langIdx, 2, function(idx)
        LANG = ({"en","de","ru"})[idx]
        saveConfig()
        for tabName, btn in pairs(tabButtons) do btn.Text = T(tabName) end
    end)
    makeToggle(p, T("hud"), 4, hudEnabled, function(s) setHudEnabled(s) end)
    makeLabel(p, T("fpslimit"), 5)
    local fpsOptions = {"15","30","45","60","90","120","144","240","999"}
    local fpsIdx = #fpsOptions
    for i, v in ipairs(fpsOptions) do
        if tonumber(v) == fpsLimit then fpsIdx = i break end
    end
    makeDropdown(p, T("fpslimit"), fpsOptions, fpsIdx, 6, function(idx, val)
        applyFpsCap(tonumber(val) or 999)
    end)
end

-- ============================================================
-- == UNLOAD + CLOSE CONFIRM ==
-- ============================================================
local function fullUnload()
    untrackAll()
    stopNpcDiscovery()
    for model in pairs(npcEntries) do removeNpcEntry(model) end
    stopItemDiscovery()
    for owner in pairs(itemEntries) do removeItemEntry(owner) end
    for plr in pairs(chamHighlights) do removeChams(plr) end
    for plr in pairs(espEntries) do cleanupESP(plr) end
    if flyEnabled then setFly(false) end
    if fullbrightEnabled then setFullbright(false) end
    if antiAfkEnabled then setAntiAfk(false) end
    if godModeEnabled then setGodMode(false) end
    if type(setfpscap) == "function" then pcall(setfpscap, 999) end
    if hudGui then pcall(function() hudGui:Destroy() end) end
    if gui then gui:Destroy() end
    if getgenv then getgenv().DeepHubLoaded = false; getgenv().DeepHubUnload = nil end
end
if getgenv then getgenv().DeepHubUnload = fullUnload end

closeBtn.MouseButton1Click:Connect(function()
    local dialog = Instance.new("ScreenGui")
    dialog.Name = "DeepHubCloseConfirm"; dialog.ResetOnSpawn = false
    dialog.DisplayOrder = 1001; dialog.Parent = parentGui
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 360, 0, 160)
    box.Position = UDim2.new(0.5, -180, 0.5, -80)
    box.BackgroundColor3 = COL_PANEL; box.BorderSizePixel = 0; box.Parent = dialog
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -20, 0, 28); ttl.Position = UDim2.new(0, 10, 0, 8)
    ttl.BackgroundTransparency = 1; ttl.Text = T("unloadTitle")
    ttl.TextColor3 = COL_TEXT; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 14
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = box
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -20, 0, 60); txt.Position = UDim2.new(0, 10, 0, 40)
    txt.BackgroundTransparency = 1; txt.Text = T("unloadText")
    txt.TextColor3 = COL_DIM; txt.Font = Enum.Font.Gotham; txt.TextSize = 12
    txt.TextWrapped = true; txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top; txt.Parent = box
    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0, 150, 0, 30); yes.Position = UDim2.new(0, 10, 1, -40)
    yes.BackgroundColor3 = Color3.fromRGB(60,30,30); yes.Text = T("yes")
    yes.TextColor3 = COL_TEXT; yes.Font = Enum.Font.GothamSemibold; yes.TextSize = 12
    yes.BorderSizePixel = 0; yes.Parent = box
    Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 6)
    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0, 150, 0, 30); no.Position = UDim2.new(1, -160, 1, -40)
    no.BackgroundColor3 = COL_ACCENT; no.Text = T("no")
    no.TextColor3 = COL_TEXT; no.Font = Enum.Font.GothamSemibold; no.TextSize = 12
    no.BorderSizePixel = 0; no.Parent = box
    Instance.new("UICorner", no).CornerRadius = UDim.new(0, 6)
    no.MouseButton1Click:Connect(function() dialog:Destroy() end)
    yes.MouseButton1Click:Connect(function()
        dialog:Destroy()
        fullUnload()
    end)
end)

-- == AUTO APPLY SAVED SETTINGS ==
task.spawn(function()
    task.wait(1)
    if type(setfpscap) == "function" then pcall(setfpscap, fpsLimit) end
    if speedEnabled then
        local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedValue end
    end
    if noclipEnabled then applyNoclip(true) end
    if flyEnabled then startFly() end
    if fullbrightEnabled then setFullbright(true) end
    if antiAfkEnabled then setAntiAfk(true) end
    if godModeEnabled then setGodMode(true, true) end
    if chamsEnabled then refreshChams() end
    if npcEspEnabled then startNpcDiscovery() end
    if itemsEspEnabled then startItemDiscovery() end
    if hudFrame then hudFrame.Visible = hudEnabled end
end)

track(LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if noclipEnabled then applyNoclip(true, char) end
    if flyEnabled then stopFly(); task.wait(0.2); startFly() end
    if godModeEnabled then applyGodHealth(char) end
end))
