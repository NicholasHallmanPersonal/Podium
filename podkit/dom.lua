--[[pod_format="raw",created="2026-10-03 23:44:39",modified="2026-10-07 12:06:43",revision=32,xstickers={}]]

function debug_dom(elm, l)
	local level = l or 1
	local s = ""
	for i = 1, level, 1 do
		s ..= " "
	end
	
	s ..= elm.name
	for k,v in pairs(elm.attributes) do
		s ..= " " .. k .. " = " .. v
	end
	
	if #elm.content > 0 then
		s ..= " " .. elm.content
	end
	printh(s)
	for child in all(elm.children) do
		debug_dom(child, level + 1)
	end
end

local function dispatch(elm, e)
	local target = elm
	e.target = elm
	local default_prevented = false
	function e:prevent_default()
		default_prevented = true
	end
	
	function record_parents(elm, parents)
		local parents = parents or {}
		if elm.parent then
			add(parents, elm.parent)
			record_parents(elm.parent, parents)
		end
		return parents
	end
	
	local parents = record_parents(target)

	for parent in all(parents) do
		for l_name, listener in pairs(parent.listeners) do
			if l_name == e.type then
				if listener(e) == false then
					default_prevented = true
				end
			end
		end
	end
end 

function add_dom_funcs(elm)
	
	elm.listeners = {}
	
	function elm:dispatch(type, data)
		dispatch(self, {type=type, data=data})
	end
end