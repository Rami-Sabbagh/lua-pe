--Lua-PE testing script

print("Lua-PE Testing Script")

local sourceDirectory = love.filesystem.getSource()
print("Source Directory:", sourceDirectory)

--Load Lua-PE
local luaPE = require("lua-pe")

--Open the .exe file which we want to change it's icon
local executable = io.open(sourceDirectory.."/love.exe","rb+")

love.event.quit() --End the execution