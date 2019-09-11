--Miscellaneous methods

--==Load libraries==--

--Require some libraries
local utf8 = require("utf8")
--TODO: Support other bitwise libraries, and Lua 5.3 native bitwise operators support
local bit = require("bit") --Use luajit bitop library for bitwise operations

--==Localize libraries functions==--
local utf8Char, utf8Codes = utf8.char, utf8.codes
local byte, char = string.byte, string.char
local lshift, rshift, band = bit.lshift, bit.rshift, bit.band
local concat = table.concat

--The methods list
local miscellaneous = {}

--Convert a utf-16 string into a utf-8 string
--Reference: https://en.wikipedia.org/wiki/UTF-16
function miscellaneous.toUTF8(str16)
    local iterPos = 0
    local stringLength = #str16

    local function nextShort()
        if iterPos > stringLength then return end
        iterPos = iterPos + 2
        return byte(str16, iterPos-1) + lshift(byte(str16, iterPos), 8)
    end
    
    local str8, unicode = {}, nextShort()
    
    while unicode do
        --Surrogate pairs
        if unicode >= 0xD800 and unicode <= 0xDBFF then
            local lowPair = nextShort()
            
            --Paired surrogate
            if lowPair and lowPair >= 0xDC00 and lowPair <= 0xDFFF then
                unicode = lshift(unicode-0xD800,10) + (lowPair-0xDC00) + 0x01000
                str8[#str8+1] = utf8Char(unicode)
                unicode = nextShort()
            else --Unpaired surrogate
                str8[#str8+1] = utf8Char(unicode)
                unicode = lowPair
            end
        else
            str8[#str8+1] = utf8Char(unicode)
            unicode = nextShort()
        end
    end
    
    return concat(str8)
end

--Convert a utf-8 string into a utf-16 string
function miscellaneous.toUTF16(str8)
    local str16 ={}
    
    for pos, unicode in utf8Codes(str8) do
        if unicode >= 0x10000 then --Encode as surrogate pair
            unicode = unicode - 0x01000
            local shortA = rshift(unicode,10)+0xD800
            local shortB = band(unicode,0x3FF)+0xDC00
            str16[#str16 + 1] = char(band(shortA,0xFF), rshift(shortA,8), band(shortB,0xFF), rshift(shortB,8))
        else
            str16[#str16 + 1] = char(band(unicode,0xFF), rshift(unicode,8))
        end
    end
    
    return concat(str16)
end

return miscellaneous