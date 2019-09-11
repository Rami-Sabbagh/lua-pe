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
    

    return self
end

return resources --Provide the class