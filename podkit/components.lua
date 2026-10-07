--[[pod_format="raw",created="2026-10-04 00:04:51",modified="2026-10-07 13:17:00",revision=117,xstickers={}]]

include "./podkit/parser.lua"
include "./ui/lib.lua"
include "./podkit/dom.lua"

local engine = nil
local buffer_reg = {}

function define(name, constructor)
	printh("define " .. name)
	if engine == nil then
		add(buffer_reg, {name, constructor})
	else
		engine.wc_registry[name] = constructor
	end
end

function check_to_promote(elm, styler)
	if elm == nil then return end
	if engine.wc_registry[elm.name] == nil then return end

	elm.should_update = true
	local comp = engine.wc_registry[elm.name]()
	
	local mt = {
		__new_index = function(t, key, value)
			if t.properties[key] then
				-- queues an update
				elm.should_update = true
			end
			t[key] = value
		end
	}
	setmetatable(comp, mt)
	
	elm._wc = comp
	-- apply styles at construction
	if comp.styles then
		styler:apply_rules(elm, comp.styles)
	end
	-- initial connection
	populate_properties(elm, comp)
	if comp.connected then
		comp:connected(elm)
	end
	-- first lifecycle
	if comp.render then
		elm.shadow_root = circumflex_elm{ name="root" }
		local results = comp:render()
		local parser = new_parser()
		parser:parse(results.template, elm.shadow_root)
		debug_dom(elm.shadow_root)
	end

end

function populate_properties(elm, comp)
	if comp.properties == nil then return end

	for k, v in pairs(comp.properties) do
		local attr_name = v.attribute or k
		if v.state == nil or v.state == false then
			-- convert the type
			local cv = convert_attribute(
				elm.attributes[attr_name], 
				v.type
			)
			comp[k] = cv 
		end
	end
end

function convert_attribute(v, type)
	local result = v
	if v.type == "number" then
		result = tonumber(v)
	elseif v.type == "bool" then
		result = v != nil
	elseif v.type == "string" or v.type == nil then
		result = v 
	end
	return result
end

function wc_extend(podkit)
	printh("extend")
	podkit.wc_registry = {}
	for to_reg in all(buffer_reg) do
		podkit.wc_registry[to_reg[1]] = to_reg[2]
	end
	engine = podkit
	local styler = new_styler()
	
	function podkit:include_and_promote()
		podkit:script_retrieve()
		podkit:promote()
	end
	
	function podkit:promote(elm)
		local cur_elm = elm or podkit.dom
		-- promote all of the components
		check_to_promote(elm, styler)
		for child in all(cur_elm.children) do
			podkit:promote(child)
		end
	end
	
	function podkit:script_retrieve(elm)
		local cur_elm = elm or podkit.dom
		-- promote all of the components
		if cur_elm.name == "script" then
			local src = cur_elm.attributes.src
			local script = fetch(src)
			local comp_definition = load(script, src, "t", {
				define = define,
				printh = printh
			})
		
			printh("loaded a script from " .. src)
			comp_definition()
		end
		for child in all(cur_elm.children) do
			podkit:script_retrieve(child)
		end
	end
end