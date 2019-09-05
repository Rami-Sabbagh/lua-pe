--A function for wrapping framework dependend file object into a unified interface.

--The path to the lua-pe module, ends with (.)
local path = string.sub((...),1,-string.len(".file"))

--==Load files classess==--
local ioFile = require(path.."file.io") --Lua standard IO file objects
local loveFile = require(path.."file.love") --LÖVE file objects

return function(file)
    --Identify the file type
    if type(file) == "userdata" then

        --Standard Lua IO file
        local ioType = io.type(file)
        if ioType then
            if ioType == "closed file" then return error("A closed file has been provided!") end
            return ioFile(file) --Wrap the file and give it back
        end

        --LÖVE file
        if file.typeOf and file:typeOf("File") then
            if not file:isOpen() then return error("A closed file has been provided!") end
            return loveFile(file) --Wrap the file and give it back
        end
    end

    return error("Unknown file object!")
end