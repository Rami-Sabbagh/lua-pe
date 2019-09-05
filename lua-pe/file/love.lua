--LÖVE file wrapper class

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".file.love"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")

--==Load file base class==--
local base = require(path.."file.base")

--==Localize libraries functions==--
local min, max = math.min, math.max

--==LÖVE File wrapper class==--

--Create the class
local loveFile = class("lua-pe.File.Love", base)

--Initialize the instance
function loveFile:initialize(file)
    self.file = file --The LÖVE file object
end

--Read an amount of bytes from the file (defaults to 1)
function loveFile:read(length)
    return (self.file:read(length or 1))
end

--Write some data into the file (only a single string is supported)
function loveFile:write(data)
    assert(self.file:write(data))
    return self
end

--Sets current position in file relative to p ("set" start of file, "cur" current [default], "end" end of file)
--adding offset, [default: zero]. Returns new position in file.
function loveFile:seek(offset, p)
    p, offset = p or "cur", offset or 0

    if p == "set" then
        assert(self.file:seek(offset), "Failed to seek to "..tostring(offset))
        return min(self.file:getSize(),offset)
    elseif p == "cur" then
        local current = self.file:tell()
        offset = current + offset
        assert(self.file:seek(offset), "Failed to seek to "..tostring(offset))
        return min(self.file:getSize(),offset)
    elseif p == "end" then
        local size = self.file:getSize()
        offset = size + offset
        assert(self.file:seek(offset), "Failed to seek to "..tostring(offset))
        return max(0,offset)
    else
        return error("Invalid argument (#2): "..tostring(p))
    end
end

--Flushes any buffered written data in the file to the disk
function loveFile:flush()
    assert(self.file:flush())
    return self
end

--Closes the file
function loveFile:close()
    assert(self.file:close(),"Failed to close the file !")
    return self
end

return loveFile --ProvideS the class