local debug = require "debug"
local io = require "io"
local collectgarbage, floor = collectgarbage, math.floor
local uhttpd = uhttpd
local pairs = pairs
local type = type
local string = string
local tostring = tostring
local select = select

module "luci.debug"
__file__ = debug.getinfo(1, 'S').source:sub(2)

-- Enables the memory tracer with given flags and returns a function to disable the tracer again
function trap_memtrace(flags, dest)
	flags = flags or "clr"
	local tracefile = io.open(dest or "/tmp/memtrace", "w")
	local peak = 0

	local function trap(what, line)
		local info = debug.getinfo(2, "Sn")
		local size = floor(collectgarbage("count"))
		if size > peak then
			peak = size
		end
		if tracefile then
			tracefile:write(
				"[", what, "] ", info.source, ":", (line or "?"), "\t",
				(info.namewhat or ""), "\t",
				(info.name or ""), "\t",
				size, " (", peak, ")\n"
			)
		end
	end

	debug.sethook(trap, flags)

	return function()
		debug.sethook()
		tracefile:close()
	end
end

local bufTable = ""
local function FormateTable(table, key, level)
	level = level or 1
	local indent = ""
	for i = 1, level do
	  indent = indent.."  "
	end
  
	if key ~= nil then
	  bufTable = bufTable .. (indent..key.." ".."=".." ".."{\n")
	else
	  bufTable = bufTable .. (indent .. "{\n")
	end
  
	for k,v in pairs(table) do
	   if type(v) == "table" then
			FormateTable(v, key, level + 1)
	   else
		   bufTable = bufTable .. string.format("%s%s = %s\n", indent .. "  ",tostring(k), tostring(v))
		end
	end
	bufTable = bufTable .. (indent .. "}\n")
end


-- 打印表
function PrintTable(table, key, level)
	bufTable = ""
	FormateTable(table, key, level)
	uhttpd.log(bufTable)
end

-- 打印单个string
function log(...)
	local s = "" 
	for i=1 , select('#',...) do 
		s = s .. " " .. tostring(select(i,...))
	end
	s = s .. "\n"

	uhttpd.log(s)
end

function ptable(tip, table)           
	log(tip)     
	PrintTable(table)              
	log(tip)            
end
