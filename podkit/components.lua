--[[pod_format="raw",created="2026-10-04 00:04:51",modified="2026-10-05 00:43:09",revision=33,xstickers={}]]

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

function check_to_promote(elm)
	if elm == nil then return end
	if engine.wc_registry[elm.name] != nil then
		printh("promoting " .. elm.name)
		local comp = engine.wc_registry[elm.name]()
		elm._wc = comp
		comp.promote(elm)
	end
end

function wc_extend(podkit)
	printh("extend")
	podkit.wc_registry = {}
	for to_reg in all(buffer_reg) do
		podkit.wc_registry[to_reg[1]] = to_reg[2]
	end
	engine = podkit
end