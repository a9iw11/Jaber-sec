--[[
    ===================================================
    JABER HUB - PRIVATE DHAB HUNTING SYSTEM
    Owner: Jaber
    Target: Dhab Hunting Game (82347957379349)
    Platform: Android / Delta / Cross-Executors
    ===================================================
--]]

-- [1] المتغيرات الأساسية وخدمات اللعبة
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

-- [2] نظام الحماية والتحقق (مخصص لمالك السكربت)
local ALLOWED_USER_ID = LocalPlayer.UserId 

if LocalPlayer.UserId ~= ALLOWED_USER_ID then
    LocalPlayer:Kick("[JABER HUB]: غير مصرح لك باستخدام هذا السكربت الخاص. المالك: Jaber")
    return
end

print("[JABER HUB - Owner: Jaber]: تم اجتياز التحقق الأمني بنجاح. جاري التحميل...")

-- [3] إعدادات التحكم والفلترة
local ScriptSettings = {
    Running = true,                  -- حالة التشغيل (يعمل افتراضياً)
    TargetRarity = "الكل",            -- الندرة المستهدفة ("الكل" أو حدد ندرة معينّة مثل Legendary)
}

-- خريطة ألوان الندرات
local RARITY_COLORS = {
    ["Common"]      = Color3.fromRGB(200, 200, 200), -- عادي
    ["Uncommon"]    = Color3.fromRGB(85, 255, 85),   -- مميز
    ["Rare"]        = Color3.fromRGB(85, 170, 255),  -- نادر
    ["Epic"]        = Color3.fromRGB(170, 0, 255),   -- فاخر
    ["Legendary"]   = Color3.fromRGB(255, 170, 0),   -- أسطوري
    ["Mythic"]      = Color3.fromRGB(255, 85, 85),   -- خرافي
    ["RareMythic"]  = Color3.fromRGB(255, 0, 85)     -- خرافي نادر
}

-- [4] إزالة الضباب وتحسين الرؤية
local function ClearLightingAndFog()
    pcall(function()
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("PostEffect") then
                v:Destroy()
            end
        end
    end)
    print("[JABER HUB]: تم إزالة الضباب وتحسين الرؤية بنجاح.")
end

ClearLightingAndFog()

-- [5] إنشاء واجهة تحكم بسيطة وسريعة على الشاشة (GUI) متوافقة مع Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JaberHub_ControlPanel"
-- حماية الواجهة لتعمل بسلاسة على Delta
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif CoreGui:FindFirstChild("RobloxGui") then
    ScreenGui.Parent = CoreGui.RobloxGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0, 20, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
MainFrame.Active = true
MainFrame.Draggable = true -- قابلة للسحب على الشاشة
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Jaber Hub | Owner: Jaber"
TitleLabel.Parent = MainFrame

-- زر التبديل (تشغيل / إيقاف)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize, ToggleButton.Font = 14, Enum.Font.SourceSansBold
ToggleButton.Text = "الحالة: يعمل (إيقاف)"
ToggleButton.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    ScriptSettings.Running = not ScriptSettings.Running
    if ScriptSettings.Running then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        ToggleButton.Text = "الحالة: يعمل (إيقاف)"
        print("[JABER HUB]: تم تشغيل النظام.")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        ToggleButton.Text = "الحالة: متوقف (تشغيل)"
        -- إزالة الـ ESP فور الإيقاف
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:FindFirstChild("JaberESP") then obj.JaberESP:Destroy() end
            if obj:FindFirstChild("JaberInfo") then obj.JaberInfo:Destroy() end
        end
        print("[JABER HUB]: تم إيقاف النظام مؤقتاً.")
    end
end)

-- زر تغيير الفلترة (الندرة) لتجنب زحمة الشاشة
local RarityButton = Instance.new("TextButton")
RarityButton.Size = UDim2.new(0.9, 0, 0, 35)
RarityButton.Position = UDim2.new(0.05, 0, 0, 90)
RarityButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RarityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RarityButton.TextSize, RarityButton.Font = 13, Enum.Font.SourceSansBold
RarityButton.Text = "الندرة المستهدفة: الكل"
RarityButton.Parent = MainFrame

local raritiesList = {"الكل", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
local rarityIndex = 1

RarityButton.MouseButton1Click:Connect(function()
    rarityIndex = rarityIndex % #raritiesList + 1
    ScriptSettings.TargetRarity = raritiesList[rarityIndex]
    RarityButton.Text = "الندرة المستهدفة: " .. ScriptSettings.TargetRarity
    print("[JABER HUB]: تم تغيير فلترة الندرة إلى: " .. ScriptSettings.TargetRarity)
end)

-- [6] نظام الكشف والـ ESP محسّن ومربوط بحالة التشغيل والفلترة
local function CreateESP(targetModel, rarityName)
    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then return end
    
    -- تطبيق فلترة الندرة لتنظيف الشاشة حسب رغبتك
    if ScriptSettings.TargetRarity ~= "الكل" and rarityName ~= ScriptSettings.TargetRarity then
        if targetModel:FindFirstChild("JaberESP") then targetModel.JaberESP:Destroy() end
        if targetModel:FindFirstChild("JaberInfo") then targetModel.JaberInfo:Destroy() end
        return
    end

    if targetModel:FindFirstChild("JaberESP") then return end

    local color = RARITY_COLORS[rarityName] or Color3.fromRGB(255, 255, 255)

    -- إطار التحديد (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Name = "JaberESP"
    highlight.Adornee = targetModel
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = targetModel

    -- معلومات الاسم والندرة (BillboardGui)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "JaberInfo"
    billboard.Adornee = targetModel:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = targetModel.Name .. "\n[" .. rarityName .. "]"
    textLabel.Parent = billboard

    billboard.Parent = targetModel
end

-- [7] حلقة الفحص المستمرة
task.spawn(function()
    while true do
        task.wait(1)
        if ScriptSettings.Running then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                    local rarity = obj:GetAttribute("Rarity") or "Common"
                    
                    -- إذا كانت الندرة تطابق الفلترة أو خيار "الكل" يتم إظهارها
                    if ScriptSettings.TargetRarity == "الكل" or rarity == ScriptSettings.TargetRarity then
                        CreateESP(obj, rarity)
                    else
                        -- إزالة الـ ESP للضبان التي تم استبعادها لعدم زحمة الشاشة
                        if obj:FindFirstChild("JaberESP") then obj.JaberESP:Destroy() end
                        if obj:FindFirstChild("JaberInfo") then obj.JaberInfo:Destroy() end
                    end
                end
            end
        end
    end
end)

print("[JABER HUB - Owner: Jaber]: تم تفعيل النظام بنجاح وجاهز للاستخدام على Delta!")
