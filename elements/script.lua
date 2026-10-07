--[[pod_format="raw",created="2026-10-07 10:22:28",modified="2026-10-07 10:35:23",revision=7,xstickers={}]]
include "./podkit/components.lua"

function make_script()
	local script = {}
	
	function script:connected(elm)
		local src = elm.attributes.src
		local script = fetch(src)
		local comp_definition = load(script, src, "t", {
			define = define,
			printh = printh
		})
		
		printh("loaded a script from " .. src)
		comp_definition()
	end
	
	return script
end

define('script', make_script)