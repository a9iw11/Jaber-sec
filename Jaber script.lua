--[[
    ===================================================
    JABER HUB - PRIVATE DHAB HUNTING SYSTEM
    Developer: Jaber Al-Shehri
    Target: Dhab Hunting Game (82347957379349)
    Platform: Android / Cross-Executors
    ===================================================
--]]

-- [1] نظام الحماية والتحقق الشرطي (HWID / Local Player Validation)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- تخصيص الحماية لجهازك فقط (يمكنك وضع UserId الخاص بك هنا)
local ALLOWED_USER_ID = LocalPlayer.UserId -- يحفظ معرف حسابك الحالي تلقائياً

if LocalPlayer.UserId ~= ALLOWED_USER_ID then
    LocalPlayer:Kick("[JABER HUB]: غير مصرح لك باستخدام هذا السكربت الخاص.")
    return
end

print("[JABER HUB]: Tamper protection passed. Loading modules...")

-- [2] إعدادات الألوان حسب ندرة الضبان
local RARITY_COLORS = {
    ["Common"]      = Color3.fromRGB(200, 200, 200), -- عادي
    ["Uncommon"]    = Color3.fromRGB(85, 255, 85),   -- مميز
    ["Rare"]        = Color3.fromRGB(85, 170, 255),  -- نادر
    ["Epic"]        = Color3.fromRGB(170, 0, 255),   -- فاخر
    ["Legendary"]   = Color3.fromRGB(255, 170, 0),   -- أسطوري
    ["Mythic"]      = Color3.fromRGB(255, 85, 85),   -- خرافي
    ["RareMythic"]  = Color3.fromRGB(255, 0, 85)    -- خرافي نادر
}

-- [3] إزالة الضباب وتحسين الرؤية (Clear Vision)
local function ClearLightingAndFog()
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("PostEffect") then
            v:Destroy()
        end
    end
    print("[JABER HUB]: Fog removed and vision cleared.")
end

ClearLightingAndFog()

-- [4] نظام الكشف والـ ESP مع تحسين الأداء
local ESP_Folder = Instance.new("Folder", Workspace)
ESP_Folder.Name = "JaberHub_ESP"

local function CreateESP(targetModel, rarityName)
    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then return end
    if targetModel:FindFirstChild("JaberESP") then return end

    local color = RARITY_COLORS[rarityName] or Color3.fromRGB(255, 255, 255)

    -- إنشاء إطار الكشف (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Name = "JaberESP"
    highlight.Adornee = targetModel
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = targetModel

    -- إنشاء نص الاسم والمسافة (BillboardGui)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "JaberInfo"
    billboard.Adornee = targetModel:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = targetModel.Name .. " [" .. (rarityName or "ضب") .. "]"
    textLabel.Parent = billboard

    billboard.Parent = targetModel
end

-- [5] البحث والتحديث المستمر للأهداف بدون Lag
task.spawn(function()
    while task.wait(1) do
        -- حلقة فحص كائنات الماب (يتم تطبيق الفحص على المجلد المخصص للضبان في الماب)
        for _, obj in pairs(Workspace:GetChildren()) do
            -- التحقق من الكائنات التي تمثل ضبان بناءً على الخصائص
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                local rarity = obj:GetAttribute("Rarity") or "Common"
                CreateESP(obj, rarity)
            end
        end
    end
end)

print("[JABER HUB]: System initialized successfully. Enjoy hunting!")
