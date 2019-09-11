--The PE Optional Header class
--Reference: https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe.peoptheader"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==PE optional header class==--

--Create the class
local peOptHeader = class("lua-pe.Pe.PEOptHeader")

local directoriesNames = {
    "Export Table",
    "Import Table",
    "Resource Table",
    "Exception Table",
    "Certificate Table",
    "Base Relocation Table",
    "Debug",
    "Architecture",
    "Global Ptr",
    "TLS Table",
    "Load Config Table",
    "Bound Import",
    "Import Address Table",
    "Delay Import Descriptor",
    "CLR Runtime Header",
    "Reserved"
}

function peOptHeader:initialize(file,dosHeader,coffHeader,parseDirectly)
    self.file = file
    self.dosHeader = dosHeader
    self.coffHeader = coffHeader

    if parseDirectly then
        self:parse()
    else
        self:new()
    end
end

function peOptHeader:new()
    self.signature = 0 --short
    self.MajorLinkerVersion = "\0" --char
    self.MinorLinkerVersion = "\0" --char
    self.SizeOfCode = 0 --long
    self.SizeOfInitializedData = 0 --long
    self.SizeOfUninitializedData = 0 --long
    self.AddressOfEntryPoint = 0 --long
    self.BaseOfCode = 0 --long
    self.BaseOfData = 0 --long, 32-bit only
    self.ImageBase = 0 --long long
    self.SectionAlignment = 0 --long
    self.FileAllignment = 0 --long
    self.MajorOSVersion = 0 --short
    self.MinorOSVersion = 0 --short
    self.MajorImageVersion = 0 --short
    self.MinorImageVersion = 0 --short
    self.MajorSubsystemVersion = 0 --short
    self.MinorSubsystemVersion = 0 --short
    self.Win32VersionValue = 0 --long
    self.SizeOfImage = 0 --long
    self.SizeOfHeaders = 0 --long
    self.Checksum = 0 --long
    self.Subsystem = 0 --short
    self.DLLCharacteristics = 0 --short
    self.SizeOfStackReserve = 0 --long long
    self.SizeOfStackCommit = 0 --long long
    self.SizeOfHeapReserve = 0 --long long
    self.SizeOfHeapCommit = 0 --long long
    self.LoaderFlags = 0 --long
    self.NumberOfRvaAndSizes = 0 --long
    self.DataDirectory = {} --data_directory[NumberOfRvaAndSizes]

    return self
end

function peOptHeader:parse()
    if self.coffHeader.SizeOfOptionalHeader == 0 then return error("The PE Optional header is not present!") end

    self.file:seek(self.dosHeader.e_lfanew+24,"set") --Seek to the PE optional header start
    --The offsets was: PE Header + COFF Header

    self.signature = self.file:readShort()
    if self.signature == 263 then return error("ROM images are not supported!") end

    local image64 = self:isHeader64()

    self.MajorLinkerVersion = self.file:read()
    self.MinorLinkerVersion = self.file:read()
    self.SizeOfCode = self.file:readLong()
    self.SizeOfInitializedData = self.file:readLong()
    self.SizeOfUninitializedData = self.file:readLong()
    self.AddressOfEntryPoint = self.file:readLong()
    self.BaseOfCode = self.file:readLong()
    self.BaseOfData = image64 and 0 or self.file:readLong() --32-bit only
    self.ImageBase = image64 and self.file:readLongLong() or self.file:readLong()
    self.SectionAlignment = self.file:readLong()
    self.FileAllignment = self.file:readLong()
    self.MajorOSVersion = self.file:readShort()
    self.MinorOSVersion = self.file:readShort()
    self.MajorImageVersion = self.file:readShort()
    self.MinorImageVersion = self.file:readShort()
    self.MajorSubsystemVersion = self.file:readShort()
    self.MinorSubsystemVersion = self.file:readShort()
    self.Win32VersionValue = self.file:readLong()
    self.SizeOfImage = self.file:readLong()
    self.SizeOfHeaders = self.file:readLong()
    self.Checksum = self.file:readLong()
    self.Subsystem = self.file:readShort()
    self.DLLCharacteristics = self.file:readShort()
    self.SizeOfStackReserve = image64 and self.file:readLongLong() or self.file:readLong()
    self.SizeOfStackCommit = image64 and self.file:readLongLong() or self.file:readLong()
    self.SizeOfHeapReserve = image64 and self.file:readLongLong() or self.file:readLong()
    self.SizeOfHeapCommit = image64 and self.file:readLongLong() or self.file:readLong()
    self.LoaderFlags = self.file:readLong()
    self.NumberOfRvaAndSizes = self.file:readLong()
    self.DataDirectory = {}
    for i=1, self.NumberOfRvaAndSizes do
        self.DataDirectory[i] = {
            Name = directoriesNames[i],
            VirtualAddress = self.file:readLong(),
            Size = self.file:readLong()
        }
    end

    return self
end

--Returns true if this is a IMAGE_OPTIONAL_HEADER64
function peOptHeader:isHeader64()
    return self.signature == 523
end

return peOptHeader --Provide the class