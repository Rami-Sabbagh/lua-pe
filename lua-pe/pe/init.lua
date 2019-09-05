--The PE class

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==Load classes==--
local dosHeader = require(path.."pe.dosheader")
local coffHeader = require(path.."pe.coffHeader")

--==PE class==--

--Create the class
local pe = class("lua-pe.PE")

function pe:initialize(file)
    self.file = file --The wrapped file object

    self.dosHeader = nil --DOS Header
    self.dosStub = nil --DOS Stub
    self.peHeader = nil --PE Header
    self.coffHeader = nil --COFF Header
end

--Parse the DOS header
function pe:parseDOSHeader(parseContent)
    self.dosHeader = dosHeader(self.file,true,parseContent)
    return self
end

--Read the DOS stub, who wants that ?
function pe:readDOSStub()
    if not self.dosHeader then error("The DOS header has to be parsed first! (without content)") end
    self.file:seek(64,"set") --Seek to the end of DOS header
    self.dosStub = self.file:read(self.dosHeader.e_lfanew-64-1) --Read all the data between the DOS header and the PE header
    return self
end

--Parse the PE header
function pe:parsePEHeader()
    if not self.dosHeader then error("The DOS header has to be parsed first! (without content)") end
    self.file:seek(self.dosHeader.e_lfanew,"set") --Seek to the PE header
    self.peHeader = self.file:read(4)
    assert(self.peHeader == "PE\0\0","Invalid PE header: "..tostring(self.peHeader))
    return self
end

--Parse the COFF header
function pe:parseCOFFHeader()
    if not self.peHeader then error("The PE header has to be parsed first!") end
    self.coffHeader = coffHeader(self.file, self.dosHeader, true)
    return self
end

return pe
