--Lua-PE testing script

print("Lua-PE Testing Script")

local sourceDirectory = love.filesystem.getSource()
print("Source Directory:", sourceDirectory)

--Load Lua-PE
local luaPE = require("lua-pe")

--Open the .exe file which we want to change it's icon
local executable = assert(io.open(sourceDirectory.."/love.exe","rb+"))

print("- Parsing love.exe")

local pe = luaPE.newPE(executable) --Get a PE instance with nothing parsed
pe:parseDOSHeader(true) --Parse the DOS header
pe:readDOSStub() --Read the DOS stub :P
pe:parsePEHeader() --Parse the PE header
pe:parseCOFFHeader() --Parse the COFF header
pe:parsePEOptHeader() --Parse the PE optional (not really) header

print("========================")
print("= love.exe Parsed Info =")
print("========================")

print("Machine:",pe.coffHeader:getMachineName())

print("Characteristics:",pe.coffHeader.Characteristics)
for k,v in pairs(pe.coffHeader:getCharacteristicsFlags()) do
    print(" - "..k.." :",tostring(v))
end

print("Checksum:",pe.peOptHeader.Checksum)
print("Number of RVAs and sizes:",pe.peOptHeader.NumberOfRvaAndSizes)

executable:close() --Close the file

love.event.quit() --End the execution