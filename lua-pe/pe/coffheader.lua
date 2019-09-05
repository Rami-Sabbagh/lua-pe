--The COFF Header class
--Reference: https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".pe.coffheader"))

--==Load libraries==--

--Middleclass library, for OO programming
--TODO: Support the usage of user's middleclass instance
local class = require(path.."middleclass")
--TODO: Support other bitwise libraries, and Lua 5.3 native bitwise operators support
local bit = require("bit") --Use luajit bitop library for bitwise operations

--==Localize libraries functions==--
local rshift, band = bit.rshift, bit.band

--==COFF header class==--

--Create the class
local coffHeader = class("lua-pe.Pe.COFFHeader")

function coffHeader:initialize(file, dosHeader, parseDirectly)
    self.file = file
    self.dosHeader = dosHeader

    if parseDirectly then
        self:parse()
    else
        self:new()
    end
end

--A new COFF header, for advanced users.
function coffHeader:new()
    self.Machine = 0 --short, This field determines what machine the file was compiled for.
    self.NumberOfSections = 0 --short, The number of sections that are described at the end of the PE headers.
    self.TimeDateStamp = 0 --long, 32 bit time at which this header was generated: is used in the process of "Binding", see below.
    self.PointerToSymbolTable = 0 --long, 
    self.NumberOfSymbols = 0 --long
    self.SizeOfOptionalHeader = 0 --short, this field shows how long the "PE Optional Header" is that follows the COFF header.
    self.Characteristics = 0 --short, This is a field of bit flags, that show some characteristics of the file.

    return self
end

--Parse the COFF header
function coffHeader:parse(parse)
    self.file:seek(self.dosHeader.e_lfanew+4,"set") --Seek to the COFF header start

    self.Machine = self.file:readShort()
    self.NumberOfSections = self.file:readShort()
    self.TimeDateStamp = self.file:readLong()
    self.PointerToSymbolTable = self.file:readLong()
    self.NumberOfSymbols = self.file:readLong()
    self.SizeOfOptionalHeader = self.file:readShort()
    self.Characteristics = self.file:readShort()

    return self
end

--A list of known machines, extraced from reference at line 2.
local knownMachinesList = {
    [0x14c] = "Intel 386",
    [0x8664] = "x64",
    [0x162] = "MIPS R3000",
    [0x168] = "MIPS R10000",
    [0x169] = "MIPS little endian WCI v2",
    [0x183] = "old Alpha AXP",
    [0x184] = "Alpha AXP",
    [0x1a2] = "Hitachi SH3",
    [0x1a3] = "Hitachi SH3 DSP",
    [0x1a6] = "Hitachi SH4",
    [0x1a8] = "Hitachi SH5",
    [0x1c0] = "ARM little endian",
    [0x1c2] = "Thumb",
    [0x1c4] = "ARMv7",
    [0x1d3] = "Matsushita AM33",
    [0x1f0] = "PowerPC little endian",
    [0x1f1] = "PowerPC with floating point support",
    [0x200] = "Intel IA64",
    [0x266] = "MIPS16",
    [0x268] = "Motorola 68000 series",
    [0x284] = "Alpha AXP 64-bit",
    [0x366] = "MIPS with FPU",
    [0x466] = "MIPS16 with FPU",
    [0xebc] = "EFI Byte Code",
    [0x8664] = "AMD AMD64",
    [0x9041] = "Mitsubishi M32R little endian",
    [0xaa64] = "ARM64 little endian",
    [0xc0ee] = "clr pure MSIL"
}

--Get the machine name
function coffHeader:getMachineName()
    return knownMachinesList[self.Machine]
end

--Check the reference for more info
local characteristicsFlags = {
    "IMAGE_FILE_RELOCS_STRIPPED",
    "IMAGE_FILE_EXECUTABLE_IMAGE",
    "IMAGE_FILE_LINE_NUMS_STRIPPED",
    "IMAGE_FILE_LOCAL_SYMS_STRIPPED",
    "IMAGE_FILE_AGGRESIVE_WS_TRIM",
    "IMAGE_FILE_LARGE_ADDRESS_AWARE",
    "UNKNOWN",
    "IMAGE_FILE_BYTES_REVERSED_LO",
    "IMAGE_FILE_32BIT_MACHINE",
    "IMAGE_FILE_DEBUG_STRIPPED",
    "IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP",
    "IMAGE_FILE_NET_RUN_FROM_SWAP",
    "IMAGE_FILE_SYSTEM",
    "IMAGE_FILE_DLL",
    "IMAGE_FILE_UP_SYSTEM_ONLY",
    "IMAGE_FILE_BYTES_REVERSED_HI"
}

--Get the characteristics flags
function coffHeader:getCharacteristicsFlags()
    local flags = {}
    for i=1,16 do
        flags[characteristicsFlags[i]] = (band(rshift(self.Characteristics,i-1),1) == 1)
    end
    return flags
end

return coffHeader --Provide the class