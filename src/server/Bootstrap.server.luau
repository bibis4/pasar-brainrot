-- ServerScriptService.Server.Bootstrap is the executable entry point.
-- Keep the bootstrap beside its ModuleScripts so all requires resolve from script.Parent.
local GameService = require(script.Parent:WaitForChild("GameService"))

GameService.Start()
