--[[pod_format="raw",created="2026-10-02 18:49:31",modified="2026-10-03 19:49:17",revision=30,xstickers={}]]

include "./ui/lib.lua"

function new_styler()

	local styler = {
		rules = {
			body = {
				dir="column",
				padding_inline = {2, 2},
				width = Fixed(0),
				height = Fit()
			},
			h1 = {
				padding_block = {6, 6},
				color = 0
			},
			h2 = {
				padding_block = {5, 5},
				color = 0
			},
			p = {
				pading_block = {4, 4},
				color = 0
			},
			a = {
				color = 16
			}
		}
	}
	
	function styler:style(elm)
		local style_rules = self.rules[elm.name]
		if style_rules != nil then
			styler:apply_rules(elm, style_rules)
			if elm.name == "a" then
				printh("a tag color " .. elm.style.color)
			end
		end
	end
	
	function styler:apply_rules(elm, rules)
		local style = elm.style
		style.layout.dir = rules.dir or style.layout.dir
		style.sizing.width = rules.width or style.sizing.width
		style.sizing.height = rules.height or style.sizing.height
		style.min_width = rules.min_width or style.min_width
		style.min_height = rules.min_height or style.min_height
		style.child_gap = rules.child_gap or style.child_gap
		style.padding_inline = rules.padding_inline or style.padding_inline
		style.padding_block = rules.padding_block or style.padding_block
		style.margin_inline = rules.margin_inline or style.margin_inline
		style.margin_block = rules.margin_block or style.margin_block
		style.background_color = rules.background_color or style.background_color
		style.border_color = rules.border_color or style.border_color
		style.color = rules.color or style.color
	end
	
	return styler
end

