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
pe:parseSectionTable() --Parse the Section table
if pe:hasResources() then pe:parseResources() end --Parse the resource if they exist

print("========================")
print("= love.exe Parsed Info =")
print("========================")

print("COFF Machine:",pe.coffHeader:getMachineName())

print("COFF Characteristics:",pe.coffHeader.Characteristics)
for k,v in pairs(pe.coffHeader:getCharacteristicsFlags()) do
    print(" - "..k.." :",tostring(v))
end

print("PEOpt Checksum:",pe.peOptHeader.Checksum)

print("Directories:",pe.peOptHeader.NumberOfRvaAndSizes)
for i=1, pe.peOptHeader.NumberOfRvaAndSizes do
    print("=----------=[ "..pe.peOptHeader.DataDirectory[i].Name.." ]=----------=")
    print("- VirtualAddress:"..pe.peOptHeader.DataDirectory[i].VirtualAddress)
    print("- Size:"..pe.peOptHeader.DataDirectory[i].Size)
end

print("Sections:",#pe.sectionTable.sections)
for i=1, #pe.sectionTable.sections do
    print("=----------=[ "..pe.sectionTable.sections[i].Name.." ]=-----------=")
    for k,v in pairs(pe.sectionTable.sections[i]) do
        print(" - "..k..": ", v)
    end
end

executable:close() --Close the file

love.event.quit() --End the execution