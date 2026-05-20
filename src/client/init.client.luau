local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

for _, module in (Modules.Init:GetChildren()) do
    local requiredModule = require(module)
    requiredModule.Init()
end

