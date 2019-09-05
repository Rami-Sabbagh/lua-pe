--The DOS Header class
--Reference: https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe.dosheader"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==COFF header class==--

--Create the class
local dosHeader = class("lua-pe.Pe.DOSHeader")

function dosHeader:initialize(file,parseDirectly,parseContent)
    self.file = file

    if parseDirectly then
        self:parse(parseContent)
    else
        self:new()
    end
end

--A new DOS header, for advanced users.
function dosHeader:new()
    self.signature = "\0\0" --char[2]
    self.lastsize = 0 --short
    self.nblocks = 0 --short
    self.nreloc = 0 --short
    self.hdrsize = 0 --short
    self.minalloc = 0 --short
    self.maxalloc = 0 --short
    self.ss = 0 --void, 2 bytes value
    self.sp = 0 --void, 2 bytes value
    self.checksum = 0 --short
    self.ip = 0 --void, 2 bytes value
    self.cs = 0 --void, 2 bytes value
    self.relocpos = 0 --short
    self.noverlay = 0 --short
    self.reserved1 = {0,0,0,0} --short[4]
    self.oem_id = 0 --short
    self.oem_info = 0 --short
    self.reserved2 = {0,0,0,0,0,0,0,0,0,0} --short[10]
    self.e_lfanew = 0 --long

    return self
end

--Parse the DOS header, if parseContent is true, then it's content is parsed, which is usually ignored.
function dosHeader:parse(parseContent)
    self.file:seek(0,"set") --Make sure the file is seeked at the start
    
    self.signature = self.file:read(2)
    assert(self.signature == "MZ", "Invalid DOS header signature: "..tostring(self.signature)..", must be: MZ")

    if parseContent then
        self.lastsize = self.file:readShort()
        self.nblocks = self.file:readShort()
        self.nreloc = self.file:readShort()
        self.hdrsize = self.file:readShort()
        self.minalloc = self.file:readShort()
        self.maxalloc = self.file:readShort()
        self.ss = self.file:readNumber(2)
        self.sp = self.file:readNumber(2)
        self.checksum = self.file:readShort()
        self.ip = self.file:readNumber(2)
        self.cs = self.file:readNumber(2)
        self.relocpos = self.file:readShort()
        self.noverlay = self.file:readShort()
        self.reserved1 = self.file:readShortArray(4)
        self.oem_id = self.file:readShort()
        self.oem_info = self.file:readShort()
        self.reserved2 = self.file:readShortArray(10)
    else
        self.file:seek(58) --Skip the header content
    end

    self.e_lfanew = self.file:readLong()

    return self
end

return dosHeader --Provide the class