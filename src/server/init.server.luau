local ServerStorage = game:GetService("ServerStorage")
local Modules = ServerStorage:WaitForChild("Modules")
local Players = game:GetService("Players")

local firstPlayer = nil

for _, module in Modules.Init:GetChildren() do
    local requiredModule = require(module)
    requiredModule.Init()
end

Players.PlayerAdded:Connect(function(player)
    if firstPlayer == nil then
        firstPlayer = player
        player:SetAttribute("HasSlider", true)
    end
end)