local ServerStorage = game:GetService("ServerStorage")
local Modules = ServerStorage:WaitForChild("Modules")

for _, module in Modules.Init:GetChildren() do
    local requiredModule = require(module)
    requiredModule.Init()
end
