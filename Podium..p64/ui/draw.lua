--[[pod_format="raw",created="2026-09-29 12:29:16",modified="2026-09-29 23:56:15",revision=46,xstickers={}]]

function bg_draw_command(elm) 
	return {
		x = elm.block.x,
		y = elm.block.y,
		width = elm.block.x + elm.block.width,
		height = elm.block.y + elm.block.height,
		background_color = elm.style.background_color,
	}
end

function border_draw_command(elm) 
	return {
		x = elm.block.x,
		y = elm.block.y,
		width = elm.block.x + elm.block.width,
		height = elm.block.y + elm.block.height,
		border_color = elm.style.border_color,
	}
end

function text_line_draw_commands(elm) 
	local line_draw_commands = {}
	for line in all(elm.lines) do
		add(line_draw_commands, {
			x = line.x,
			y = line.y,
			content = line.content,
			color = elm.style.color
		})
	end
	return line_draw_commands
end

function make_draw_list(elm, list)
	local draw_list = list or {}
	-- background
	if elm.style.background_color then
		add(draw_list, bg_draw_command(elm))
	end
	-- border
	if elm.style.border_color then
		add(draw_list, border_draw_command(elm))
	end
	-- text
	for line_draw_command in all(text_line_draw_commands(elm)) do
		add(draw_list, line_draw_command)
	end
	
	for child in all(elm.children) do
		make_draw_list(child, draw_list)
	end
	return draw_list
end

function draw_layout(draw_list)
	for v in all(draw_list) do
		if v.background_color then
			rectfill(v.x, v.y, v.width, v.height, v.background_color)
		end
		if v.border_color then
			rect(v.x, v.y, v.width, v.height, v.border_color)
		end
		
		if v.content then
			print(v.content, v.x, v.y, v.color)
		end
	end
end