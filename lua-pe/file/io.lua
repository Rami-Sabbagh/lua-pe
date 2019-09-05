--Lua standard io file wrapper class

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".file.io"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==Load file base class==--
local base = require(path.."file.base")

--==IO File wrapper class==--

--Create the class
local ioFile = class("lua-pe.File.Io", base)

--Initialize the instance
function ioFile:initialize(file)
    self.file = file --The standard io file object
end

--Read an amount of bytes from the file (defaults to 1)
function ioFile:read(length)
    return assert(self.file:read(length or 1))
end

--Write some data into the file (only a single string is supported)
function ioFile:write(data)
    assert(self.file:write(data))
    return self
end

--Sets current position in file relative to p ("set" start of file, "cur" current [default], "end" end of file)
--adding offset, [default: zero]. Returns new position in file.
function ioFile:seek(offset, p)
    return assert(self.file:seek(p or "cur", offset or 0))
end

--Flushes any buffered written data in the file to the disk
function ioFile:flush()
    assert(self.file:flush())
    return self
end

--Closes the file
function ioFile:close()
    assert(self.file:close())
    return self
end

return ioFile --Provide the class