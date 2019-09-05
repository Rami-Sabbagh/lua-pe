--File base class, inorder to support multiple io libraries, like standard io, LÖVE, virtual file from string, etc...

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".file.base"))

--==Load Libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
--TODO: Support other bitwise libraries, and Lua 5.2 native bitwise operators support
local class = require(path.."middleclass")
local bit = require("bit") --Use luajit bitop library for bitwise operations

--==Localize libraries functions==--
local char, byte = string.char, string.byte
local rshift, lshift, band = bit.rshift, bit.lshift, bit.band

--==File base class==--

--Create the class
local base = class("lua-pe.File.Base")

function base:initialize() end

--Read an amount of bytes from the file (defaults to 1), must be overidden by sub-classes
function base:read(length) return string.rep("\0",length or 1) end

--Write some data into the file (only a string is supported), must be overridden by sub-classes
function base:write(data) return self end

--Read a number in little-endian format, length is measured in bytes
function base:readNumber(length)
    local str = self:read(length) --String containing the number characters
    local num = 0 --The number we are reading

    for i=1,length do
        num = num + lshift(byte(str,i),i*8)
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

return base