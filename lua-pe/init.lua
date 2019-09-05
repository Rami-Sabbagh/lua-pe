--Lua-PE library by RamiLego4Game (Rami Sabbagh)
--A library for parsing and manupilating windows PE files.

--The path to the lua-pe module, ends with (.)
local path = (...).."."

--The file wrapper, for a unified interface.
local wrapFile = require(path.."file")

--The PE class, the core of this library
local pe = require(path.."pe")

--The library API
local luaPE = {}

--==Advanced users methods==--

--Give a new PE instance with nothing parsed.
function luaPE.newPE(file)
    local wrappedFile = wrapFile(file)
    return pe(wrappedFile)
end

return luaPE --Provide the library's API