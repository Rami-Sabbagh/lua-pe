--The PE class

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==Load classes==--
local dosHeader = require(path.."pe.dosheader")

--==PE class==--

--Create the class
local pe = class("lua-pe.Pe")

function pe:initialize(file)
    self.file = file --The wrapped file object

    self.dosHeader = nil --DOS Header
end

--Parse the DOS header
function pe:parseDOSHeader(parseContent)
    self.dosHeader = dosHeader(self.file,true,parseContent)
end

return pe
