--Lua-PE library by RamiLego4Game (Rami Sabbagh)
--A library for parsing and manupilating windows PE files.

--The path to the lua-pe module, ends with (.)
local path = (...).."."

--The file wrapper, for a unified interface.
local wrapFile = require(path.."file")