--File base class, inorder to support multiple io libraries, like standard io, LÖVE, virtual file from string, etc...

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".file.base"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")
--TODO: Support other bitwise libraries, and Lua 5.3 native bitwise operators support
local bit = require("bit") --Use luajit bitop library for bitwise operations

--==Localize libraries functions==--
local char, byte = string.char, string.byte
local rshift, lshift, band = bit.rshift, bit.lshift, bit.band

--==File base class==--

--Create the class
local base = class("lua-pe.File.Base")

--==Backend dependant methods==--

--Must be overriden by sub-classes
function base:initialize(file)
    self.file = file --The original non-universal file object
end

--Read an amount of bytes from the file (defaults to 1), must be overidden by sub-classes
function base:read(length) return string.rep("\0",length or 1) end

--Write some data into the file (only a single string is supported), must be overridden by sub-classes
function base:write(data) return self end

--Sets current position in file relative to p ("set" start of file, "cur" current [default], "end" end of file)
--adding offset, [default: zero]. Returns new position in file.
--Must be overridden by sub-classes
function base:seek(offset, p) return 0 end

--Flushes any buffered written data in the file to the disk, must be overridden by sub-classes
function base:flush() return self end

--Closes the file, must be overridden by sub-classes
function base:close() return self end

--==Backend independent (shared) methods==--

--Read a number in little-endian format, length is measured in bytes
function base:readNumber(length)
    local str = self:read(length) --String containing the number characters
    local num = 0 --The number we are reading

    for i=1,length do
        num = num + lshift(byte(str,i),(i-1)*8)
    end

    return num
end

--Write a number in little-endian format, length is measured in bytes
function base:writeNumber(length, num)
    local bytes = {} --The seperated bytes values
    for i=1, length do
        bytes[i] = band(num,0xFF) --Mask a single byte
        num = rshift(num, 8) --Discard the masked byte
    end

    self:write(char(unpack(bytes))) --Convert the bytes array into a string and write it into the file

    return self --Allow nested calls
end

--Read a short number (2 bytes long).
function base:readShort() return self:readNumber(2) end

--Write a short number (2 bytes long).
function base:writeShort(num) return self:writeNumber(2, num) end

--Read an array of short numbers (2 bytes long).
function base:readShortArray(count)
    local array = {}
    for i=1, count do array[i] = self:readShort() end
    return array
end

--Write an array of short numbers (2 bytes long).
function base:writeShortArray(array)
    for i=1, #array do self:writeShort(array[i]) end
    return self
end

--Read a long number (4 bytes long).
function base:readLong() return self:readNumber(4) end

--Write a long number (4 bytes long).
function base:writeLong(num) return self:writeNumber(4, num) end

--Read a long long number (8 bytes long).
function base:readLongLong() return self:readNumber(8) end

--Write a long lonf number (8 bytes long).
function base:writeLongLong(num) return self:writeNumber(8, num) end

return base --Provide the base class