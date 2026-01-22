--lua/SessionModule.lua
--new() starts on line 160 and also calls save()
--save() starts on line 200 and also calls serialize(), together with a (callback?) function
--serialize() starts on line 102
local assert, error, ipairs, pairs, loadfile, dofile, next, tostring, type = assert, error, ipairs, pairs, loadfile, dofile, next, tostring, type
local format, gsub, strfind, strsub = string.format, string.gsub, string.find, string.sub
local sort, tinsert = table.sort, table.insert
local string, math = string, math
local _open, _write = io.open, io.write
local remove, time, clock = os.remove, os.time, os.clock
local rawset, pcall, print = rawset, pcall, print
local fileexist, filetime, mkdir, currentdir, chmod, isfolder = c_FileExist, c_GetFileTime, c_MkDir, c_GetAppPath, c_Chmod, c_IsDir
local md5, var_dump, c_GetTimeUS, c_GetRandom, c_GetServerID, c_RestrictSessionIP = md5, var_dump, c_GetTimeUS, c_GetRandom, c_GetServerID, c_RestrictSessionIP
local _SESSION, _REMOTE_IP = _SESSION, _REMOTE_IP
local domain = domain

module("SessionModule")

local INVALID_SESSION_ID = "Invalid Session ID"
local root_dir = currentdir().."/session"
local timeout = 600

local function value (v, outf, ind, pre)
	local t = type (v)
	if t == "string" then
		outf (format ("%q", v))
	elseif t == "number" then
		outf (tostring(v))
	elseif t == "boolean" then
		outf (tostring(v))
	elseif t == "table" then
		tabledump (v, outf, ind, pre)
	else
		outf (format ("%q", tostring(v)))
	end
end

function tabledump (tab, outf, ind, pre)
	local sep_n, sep, _n = ",\n", ", ", "\n"
	if (not ind) or (ind == "") then ind = ""; sep_n = ", "; _n = "" end
	if not pre then pre = "" end
	outf ("_SESSION = {")
	local p = pre..ind
	local keys = { boolean = {}, number = {}, string = {} }
	local total = 0
	for key in pairs (tab) do
		total = total + 1
		local t = type(key)
		if t == "string" then
			tinsert (keys.string, key)
		else
			keys[t][key] = true
		end
	end
	local many = total > 5
	if not many then sep_n = sep; _n = " " end
	outf (_n)
	if many then
		local _f,_s,_v = ipairs(tab)
		if _f(_s,_v) then outf (p) end
	end
	local num = keys.number
	local ok = false
	for key, val in ipairs (tab) do
		value (val, outf, ind, p)
		outf (sep)
		num[key] = nil
		ok = true
	end
	if ok and many then outf (_n) end
	for key in pairs (num) do
		if many then outf (p) end
		outf ("[")
		outf (key)
		outf ("] = ")
		value (tab[key], outf, ind, p)
		outf (sep_n)
	end
	local tr = keys.boolean[true]
	if tr then
		outf (format ("%s[true] = ", many and p or ''))
		value (tab[true], outf, ind, p)
		outf (sep_n)
	end
	local fa = keys.boolean[false]
	if fa then
		outf (format ("%s[false] = ", many and p or ''))
		value (tab[false], outf, ind, p)
		outf (sep_n)
	end
	sort (keys.string)
	for _, key in ipairs (keys.string) do
		outf (format ("%s[%q] = ", many and p or '', key))
		value (tab[key], outf, ind, p)
		outf (sep_n)
	end
	if many then outf (pre) end
	outf ("}")
end


function serialize(tab,outf)
	if type(tab) == "table" then
		for k,v in pairs(tab) do
			if type(k) == "string" then k="'"..k.."'" end
			if(type(v) == "string") then
				outf("_SESSION["..k.."]=[["..v.."]]\r\n")
			elseif(type(v) == "number") then
				outf("_SESSION["..k.."]="..v.."\r\n")
			elseif(type(v) == "function") then
				outf("_SESSION["..k.."]=\"[function]\"\r\n")
			elseif(type(v) == "nil") then
				outf("_SESSION["..k.."]=nil\r\n")
			else
				outf("_SESSION["..k.."]={")
				serialize(v,outf)
				outf("}\r\n")
			end
		end
	end
end


local function check_id (id)
	return id and (strfind (id, "^%w+$") ~= nil)
end


local function filename (id)
	return format ("%s/%s.lua", root_dir, id)
end


function delete (id)
	if not check_id (id) then
		return nil, INVALID_SESSION_ID
	end

	_SESSION = {}
	remove (filename (id))
end


local function find (filename)
	local fh = _open (root_dir.."/"..filename)
	if fh then
		fh:close ()
		return true
	else
		return false
	end
end


local function new_id ()
	return md5( (c_GetTimeUS() + c_GetRandom())..c_GetServerID().._REMOTE_IP..domain )..md5(_REMOTE_IP)
end


function new ()
	local id = new_id ()
	save(id)
	return id
end


function load (id)
	if not check_id (id) then
		return false
	end

	local filepath = filename(id)
	if fileexist(filepath) then
		if filetime(filepath) + timeout < time() then
			remove(filepath)
			return false
		end

		local ipHash = string.sub(id, -32)
		if c_RestrictSessionIP() == true and ipHash ~= md5(_REMOTE_IP) then
			return false
		end

		if ipHash == "f528764d624db129b32c21fbca0cb8d6" and _REMOTE_IP ~= "127.0.0.1" then
			return false
		end

		local f, err = loadfile(filepath)
		if not f then
			return false
		else
			f()
			return true
		end

	end
end


function save (id)
	if not check_id (id) then
		return nil, INVALID_SESSION_ID
	end

	if isfolder(root_dir) == false then
		mkdir(root_dir)
		chmod(root_dir, "0600")
	end

	local fh = assert(_open(filename (id), "w+"))
	serialize(_SESSION, function (s) fh:write(s) end)
	fh:close()
	chmod(filename(id), "0600")
end


