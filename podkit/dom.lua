--[[pod_format="raw",created="2026-10-03 23:44:39",modified="2026-10-04 22:54:36",revision=31,xstickers={}]]


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