local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Players = game:GetService("Players")
local GUI = ReplicatedStorage:WaitForChild("GUI")
local SliderModule = require(Modules:WaitForChild("Slider"))
local Load = {}

function Load.Init()
    if not Players.LocalPlayer:GetAttribute("HasSlider") then return end
    local PossibleSliderUI = GUI:FindFirstChild("Slider")
    if PossibleSliderUI then
        PossibleSliderUI.Parent = Players.LocalPlayer.PlayerGui
        SliderModule.new(PossibleSliderUI)
    end
end

return Load