--The Resources section class
--Reference: https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe.resources"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==DOS header class==--

--Create the class
local resources = class("lua-pe.Pe.Resources")

function resources:initialize(file,peOptHeader,sectionTable,parseDirectly)
    self.file = file
    self.peOptHeader = peOptHeader
    self.sectionTable = sectionTable

    if parseDirectly then
        self:parse()
    else
        self:new()
    end
end

--A new DOS header, for advanced users.
function resources:new()
    

    return self
end

--Parse the DOS header, if parseContent is true, then it's content is parsed, which is usually ignored.
function resources:parse(parseContent)
    --Calculate the resources offset
    local ResourcesRVA = self.peOptHeader.DataDirectory[3].VirtualAddress
    local ResourcesOffset = self.sectionTable:convertRVA2Offset(ResourcesRVA)

    --Seek to the resources start
    self.file:seek(ResourcesOffset,"set")

    self.resources, self.meta = self:_parseDirectoryTable()
    
    return self
end

--==Internal methods==--

--Parse a directory table and return it
function resources:_parseDirectoryTable()
    local meta = {
        Characteristics = self.file:readLong(),
        TimeDateStamp = self.file:readLong(),
        MajorVersion = self.file:readShort(),
        MinorVersion = self.file:readShort(),
        NumberOfNameEntries = self.file:readShort(),
        NumberOfIDEntries = self.file:readShort(),

        NameEntries = {},
        IDEntries = {},
        Entries = {}
    }

    for i=1, meta.NumberOfNameEntries + meta.NumberOfIDEntries do
        local entry = {}

        if i <= meta.NumberOfNameEntries then
            entry.NameOffset = self.file:readLong()
            meta.NameEntries[#meta.NameEntries + 1] = entry
        else
            entry.ID = self.file:readLong()
            meta.IDEntries[#meta.NameEntries + 1] = entry
        end

        local Offset = self.file:readLong()

        if Offset >= 0x80000000 then
            entry.SubdirectoryOffset = Offset - 0x80000000
        else
            entry.DataEntryOffset = Offset
        end
        
        meta.Entries[#meta.Entries + 1] = entry
    end

    return {}, meta
end

return resources --Provide the class