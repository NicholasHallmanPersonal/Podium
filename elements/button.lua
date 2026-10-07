--[[pod_format="raw",created="2026-10-07 10:49:05",modified="2026-10-07 10:51:34",revision=6,xstickers={}]]
include "./podkit/components.lua"

function make_button()
	button = {
		styles = {
			padding_inline = {4, 4},
			padding_block = {2, 2},
			background_color = 6,
			border_color = 13,
			color = 0
		}
	}
	return button
end

define("button", make_button)