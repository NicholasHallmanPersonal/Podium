--[[pod_format="raw",created="2026-09-29 12:29:16",modified="2026-10-04 21:41:45",revision=140,xstickers={}]]

local function bg_draw_command(sb, elm) 
	return {
		x = sb.x,
		y = sb.y,
		width = sb.width,
		height = sb.height,
		background_color = elm.style.background_color,
	}
end

local function border_draw_command(sb, elm) 
	return {
		x = sb.x,
		y = sb.y,
		width = sb.width,
		height = sb.height,
		border_color = elm.style.border_color,
	}
end

local function text_line_draw_commands(sb, elm) 
	local line_draw_commands = {}
	local i = 0
	for line in all(elm.lines) do
		add(line_draw_commands, {
			x = sb.x,
			y = sb.y + ( i * 10),
			width = sb.width,
			height = sb.height,
			content = line.content,
			color = elm.parent.style.color
		})
		i += 1
	end
	return line_draw_commands
end

draw = {}

function draw:to_screen_space(block, frame)
	return {
		x = block.x + frame.x,
		y = block.y + frame.y - frame.scroll,
		width = block.width,
		height = block.height
	}
end

function draw:make_draw_list(elm, frame, list)
	local draw_list = list or {}
	
	local sb = draw:to_screen_space(elm.block, frame)
	
	local hit = (sb.x < frame.x + frame.width and
   	sb.x + sb.width > frame.x and
      sb.y < frame.y + frame.height and
      sb.y + sb.height > frame.y)

	if hit then
		-- background
		if elm.style.background_color then
			add(draw_list, bg_draw_command(sb, elm))
		end
		-- border
		if elm.style.border_color then
			add(draw_list, border_draw_command(sb, elm))
		end
		-- text
		for line_draw_command in all(text_line_draw_commands(sb, elm)) do
			add(draw_list, line_draw_command)
		end
		
		for child in all(elm.children) do
			draw:make_draw_list(child, frame, draw_list)
		end
	end
	
	return draw_list
end

function draw:draw_layout(draw_list, frame)

	for v in all(draw_list) do
		local x1 = v.x 
		local y1 = v.y
		local x2 = x1 + (v.width or 0)
		local y2 = y1 + (v.height or 0)
		
		if v.background_color then
			rectfill(x1, y1, x2, y2, v.background_color)
		end
		if v.border_color then
			rect(x1, y1, x2, y2, v.border_color)
		end
		if v.content then
			print(v.content, x1, y1, v.color)
		end
	end
end