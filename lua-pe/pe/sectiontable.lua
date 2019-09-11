--The Section Table class
--Reference: https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe.sectiontable"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==Section table class==--

--Create the class
local sectionTable = class("lua-pe.Pe.SectionTable")

function sectionTable:initialize(file,dosHeader,coffHeader,parseDirectly)
    self.file = file
    self.dosHeader = dosHeader
    self.coffHeader = coffHeader

    if parseDirectly then
        self:parse()
    else
        self:new()
    end
end

function sectionTable:new()
    self.sections = {}
    for i=1, self.coffHeader.NumberOfSections do
        self.sections[i] = {
            Name = "\0\0\0\0\0\0\0\0", --8 characters
            Misc = {
                PhysicalAddress = 0, --long
                VirtualSize = 0 --long
            },
            VirtualAddress = 0, --long
            SizeOfRawData = 0, --long
            PointerToRawData = 0, --long
            PointerToRelocations = 0, --long
            PointerToLinenumbers = 0, --long
            NumberOfRelocations = 0, --short
            NumberOfLinenumbers = 0, --short
            Characteristics = 0 --long
        }
    end
end

function sectionTable:parse()
    --Seek to the section table
    self.file:seek(self.dosHeader.e_lfanew + 24 + self.coffHeader.SizeOfOptionalHeader,"set")

    self.sections = {}
    for i=1, self.coffHeader.NumberOfSections do
        self.sections[i] = {
            Name = self.file:read(8):match("%Z*"),
            VirtualSize = self.file:readLong(),
            VirtualAddress = self.file:readLong(),
            SizeOfRawData = self.file:readLong(),
            PointerToRawData = self.file:readLong(),
            PointerToRelocations = self.file:readLong(),
            PointerToLinenumbers = self.file:readLong(),
            NumberOfRelocations = self.file:readShort(),
            NumberOfLinenumbers = self.file:readShort(),
            Characteristics = self.file:readLong(),
            RawData = ""
        }
    end
end

return sectionTable --Provide the class