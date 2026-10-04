--[[pod_format="raw",created="2026-10-04 00:03:55",modified="2026-10-04 00:25:30",revision=11,xstickers={}]]




function new_anchor()
	local anchor = {}
	
	function anchor:promote(elm)
		elm.listeners[click] = anchor.handle_click
	end
	
	return anchor
end

define("a", new_anchor)