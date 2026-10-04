--[[pod_format="raw",created="2026-10-04 00:04:51",modified="2026-10-04 00:11:07",revision=6,xstickers={}]]

local engine = nil

function define(name, constructor)
	engine.wc_registry[name] = constructor
end

function wc_extend(podkit)
	podkit.wc_registry = {}
	engine = podkit
end