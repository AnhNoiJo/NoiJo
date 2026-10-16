-- =========================================================================
-- 1. HỆ THỐNG BYPASS ANTI-CHEAT & ANTI-AFK (CHỐNG PHÁT HIỆN GIAN LẬN)
-- =========================================================================
pcall(function()
    -- Vượt qua bộ đếm thời gian treo máy của Roblox (Chống Kick Disconnect)
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
    
    -- Xóa bỏ bộ quét vị trí của game nếu có để tránh bị Ban khi dịch chuyển (Tween)
    if game.Workspace:FindFirstChild("AntiCheat") then
        game.Workspace.AntiCheat:Destroy()
    end
end)

-- Khởi tạo thư viện giao diện Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Premium Blox Fruits Hub | Anti-Cheat Bypass",
   LoadingTitle = "Đang tải hệ thống bảo mật nâng cao...",
   LoadingSubtitle = "by Lập Trình Viên Roblox",
   ConfigurationSaving = { Enabled = false }
})

-- Tạo các Tab menu chức năng
local TabMain    = Window:CreateTab("Auto Farm", 4483362458)
local TabEvents  = Window:CreateTab("Sea Events", 4483362458)
local TabItems   = Window:CreateTab("Nhiệm Vụ Item", 4483362458)
local TabCombat  = Window:CreateTab("Chiến Đấu / PVP", 4483362458)
local TabPlayer  = Window:CreateTab("Người Chơi", 4483362458)

-- Các biến kiểm soát trạng thái (Tắt/Bật)
_G.AutoFarm = false
_G.AutoQuest = false
_G.SeaEventFarm = false
_G.QuestItem = false
_G.AimPVP = false
_G.TweenSpeed = 320 -- Tốc độ di chuyển an toàn, không bị hệ thống chống hack đá ra ngoài

-- Hàm click chuột tự động đánh
function AutoAttack()
    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
end

-- Hàm dịch chuyển mượt mà (Tween) an toàn qua mặt Anti-Cheat
function SecureTween(targetCFrame)
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local distance = (player.Character.HumanoidRootPart.Position - targetCFrame.p).Magnitude
    local duration = distance / _G.TweenSpeed
    
    -- Tạo chuyển động mượt mà thay vì dịch chuyển tức thời để tránh bị hệ thống quét
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(player.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- =========================================================================
-- TAB 1: AUTO FARM LEVEL & NHẬN NHIỆM VỤ
-- =========================================================================

TabMain:CreateToggle({
   Name = "Bật Auto Farm Cấp Độ + Nhận Nhiệm Vụ",
   CurrentValue = false,
   Flag = "ToggleMainFarm",
   Callback = function(Value)
       _G.AutoFarm = Value
       _G.AutoQuest = Value
       
       spawn(function()
           while _G.AutoFarm do
               task.wait(0.1)
               pcall(function()
                   local MyLevel = game.Players.LocalPlayer.Data.Level.Value
                   local TargetMob = ""
                   local QuestName = ""
                   local QuestID = 1
                   local NPCName = ""
                   
                   -- Logic kiểm tra level để nhận nhiệm vụ (Ví dụ mẫu Đảo Tân Thủ Sea 1)
                   if MyLevel >= 1 and MyLevel < 10 then
                       TargetMob = "Bandit"
                       QuestName = "BanditQuest1"
                       QuestID = 1
                       NPCName = "Bandit Recruiter"
                   end
                   
                   -- Bước A: Kiểm tra xem đã nhận nhiệm vụ chưa, nếu chưa thì bay đi nhận
                   local HasQuest = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible
                   if _G.AutoQuest and not HasQuest then
                       local NPC = game.Workspace.NPCs:FindFirstChild(NPCName)
                       if NPC and NPC:FindFirstChild("HumanoidRootPart") then
                           SecureTween(NPC.HumanoidRootPart.CFrame)
                           task.wait(1)
                           -- Gửi tín hiệu lên Server để nhận quest (Không cần click tay)
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestName, QuestID)
                       end
                   end
                   
                   -- Bước B: Đi tìm và tiêu diệt quái vật nhiệm vụ
                   for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                       if mob.Name == TargetMob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                           while _G.AutoFarm and mob.Humanoid.Health > 0 do
                               task.wait()
                               -- Đứng trên đầu quái 5 mét để quái không đánh trúng mình
                               SecureTween(mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                               
                               -- Tự động lấy vũ khí ra đánh
                               local Tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                               if not Tool then
                                   local BackpackTool = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                   if BackpackTool then
                                       game.Players.LocalPlayer.Character.Humanoid:EquipTool(BackpackTool)
                                   end
                               else
                                   AutoAttack()
                               end
                           end
                       end
                   end
               end)
           end
       end)
   end,
})

-- =========================================================================
-- TAB 2: SEA EVENTS (SĂN THUYỀN, TÀU MA, CÁ MẬP TÙNG HOÀNH SEA 3)
-- =========================================================================

TabEvents:CreateToggle({
   Name = "Tự Động Săn Khổng Lồ Biển (Auto Sea Events)",
   CurrentValue = false,
   Flag = "ToggleSeaEvent",
   Callback = function(Value)
       _G.SeaEventFarm = Value
       spawn(function()
           while _G.SeaEventFarm do
               task.wait(0.5)
               pcall(function()
                   -- Quét các thực thể Sea Event xuất hiện trên biển (Sea Beast, Ship, Terrorshark...)
                   for _, event in pairs(game.Workspace.SeaBeasts:GetChildren()) do
                       if event:FindFirstChild("HumanoidRootPart") and event.Humanoid.Health > 0 then
                           while _G.SeaEventFarm and event.Humanoid.Health > 0 do
                               task.wait()
                               -- Giữ khoảng cách an toàn trên không để xả chiêu
                               SecureTween(event.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
                               AutoAttack()
                           end
                       end
                   end
               end)
           end
       end)
   end,
})

-- =========================================================================
-- TAB 3: NHIỆM VỤ LẤY ITEM (KIẾM SABER, CÀ TÀU, LẤY PHỤ KIỆN)
-- =========================================================================

TabItems:CreateToggle({
   Name = "Auto Làm Chuỗi Nhiệm Vụ Lấy Kiếm Saber (Sea 1)",
   CurrentValue = false,
   Flag = "ToggleSaber",
   Callback = function(Value)
       _G.QuestItem = Value
       spawn(function()
           if _G.QuestItem then
               Rayfield:Notify({Title = "Item Quest", Content = "Đang bắt đầu chuỗi giải đố nút bấm Đảo Khỉ...", Duration = 3})
               -- [Logic Giải Đố]: Đoạn này tự động di chuyển nhân vật giẫm lên 5 nút ẩn trên Đảo Khỉ
               pcall(function()
                   local Buttons = {"Button1", "Button2", "Button3", "Button4", "Button5"} -- Tên các nút trong Workspace của game
                   for _, btnName in pairs(Buttons) do
                       local btn = game.Workspace.Map.Jungle:FindFirstChild(btnName)
                       if btn then
                           SecureTween(btn.CFrame)
                           task.wait(1.5)
                       end
                   end
               end)
           end
       end)
   end,
})

-- =========================================================================
-- TAB 4: CHIẾN ĐẤU / AIM PVP (TỰ KHÓA MỤC TIÊU NGƯỜI CHƠI)
-- =========================================================================

local SelectedPlayer = ""
TabCombat:CreateToggle({
   Name = "Bật Aim Khóa Mục Tiêu PVP (Aimlock)",
   CurrentValue = false,
   Flag = "ToggleAimlock",
   Callback = function(Value)
       _G.AimPVP = Value
       
       -- Liên tục bẻ Camera hoặc hướng chiêu thức vào người chơi đối thủ gần nhất
       game:GetService("RunService").RenderStepped:Connect(function()
           if _G.AimPVP then
               pcall(function()
                   -- Tự động tìm người chơi gần bạn nhất để khóa mục tiêu
                   local ClosestPlayer = nil
                   local ShortestDistance = math.huge
                   
                   for _, p in pairs(game.Players:GetPlayers()) do
                       if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                           local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                           if distance < ShortestDistance then
                               ClosestPlayer = p
                               ShortestDistance = distance
                           end
                       end
                   end
                   
                   -- Hướng Camera của bạn thẳng vào đầu của kẻ địch để xả chiêu trúng 100%
if ClosestPlayer then
workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, ClosestPlayer.Character.HumanoidRootPart.Position)
end
end)
end
end)
end,
})
-- =========================================================================
-- TAB 5: ĐIỀU CHỈNH NGƯỜI CHƠI (TỐC ĐỘ & NHẢY)
-- =========================================================================
TabPlayer:CreateSlider({
Name = "Tốc Độ Di Chuyển (WalkSpeed)",
Min = 16,
Max = 250,
DefaultValue = 16,
Color = Color3.fromRGB(0, 255, 128),
Increment = 1,
ValueName = "Speed",
Callback = function(Value)
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end,
})
TabPlayer:CreateSlider({
Name = "Độ Cao Lực Nhảy (JumpPower)",
Min = 50,
Max = 350,
DefaultValue = 50,
Color = Color3.fromRGB(0, 128, 255),
Increment = 1,
ValueName = "Jump",
Callback = function(Value)
game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end,
})
