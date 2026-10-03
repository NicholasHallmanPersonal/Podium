--[[pod_format="raw",created="2026-09-29 12:19:42",modified="2026-10-03 19:38:18",revision=296,xstickers={}]]

function Fixed(v) return { tag = "Fixed", v = v } end
function Fit() return { tag = "Fit" } end
function Grow(v) return { tag = "Grow", v = v or 1 } end
function Shrink(v) return { tag = "Shrink", v = v or 1 } end

local character_widths = {}

local function size_word(word)
	local sb = userdata("u8", 6, 10)
	local acc = 0
	for i = 1, #word, 1 do
		local char = sub(word, i, true)
		if character_widths[char] == nil then
			set_draw_target(sb)
			local size = print(char, 0, 0)
			character_widths[char] = size
			set_draw_target()
		end
		acc += character_widths[char]
	end
	return acc
end

local function size_text_content(content)
	-- find the length of the content and 
	-- each word
	local max_word = 0
	local word_size_acc = 0
	local lines = split(content, "\n")
	for l in all(lines) do
		local words = split(l, " ")
		for w in all(words) do
			local size = size_word(w) 
			if size > max_word then max_word = size end
			word_size_acc += size + 5
		end
	end 
	word_size_acc = max(word_size_acc - 5, 0)
	print("size of " .. content .. "   .. max_word" ) 
	return {max_word, word_size_acc}
end

local function clean(elm)
	elm.block.width = 0
	elm.block.height = 0
	elm.block.min_width = elm.style.min_width or 0
	elm.block.min_height = elm.style.min_height or 0
	elm.block.x = 0
	elm.block.y = 0
	elm.lines = {}
	for child in all(elm.children) do
		clean(child)
	end
end

local function fit_size_width(elm)

	if elm.name == "text" then
		-- our prefered width is the full length of the content
		-- our min width is the largest word
		-- text elements cant have children so we just return after
		local sizes = size_text_content(elm.content)
		elm.block.width = sizes[2]
		elm.block.min_width = sizes[1]
		return
	end

	local is_row = elm.style.layout.dir == "row"

	local child_acc = elm.style.padding_inline[1]
	local child_min_acc = elm.style.padding_inline[1]
	local max_child = 0
	for child in all(elm.children) do
		fit_size_width(child)
		if is_row then
			child_acc += child.block.width
			child_min_acc += child.block.min_width
		else
			-- off axis, find biggest child width
			if child.block.width > max_child then
				max_child = child.block.width
			end
		end
	end
	
	if elm.style.sizing.width.tag == "Fixed" then
		elm.block.width = elm.style.sizing.width.v
		elm.block.min_width = elm.block.width
	else
		local total_gap = #elm.children > 0
			and (#elm.children - 1) * elm.style.child_gap
			or 0
		if is_row then
			elm.block.min_width = max(child_min_acc + total_gap 
				+ elm.style.padding_inline[2], elm.block.min_width)
			elm.block.width = max(child_acc + total_gap 
				+ elm.style.padding_inline[2], elm.block.min_width)
		else
			elm.block.min_width = max(elm.style.padding_inline[1] + 
				max_child + elm.style.padding_inline[2], 
				elm.block.min_width)
			elm.block.width = max(elm.style.padding_inline[1] + 
				max_child + elm.style.padding_inline[2], elm.block.min_width)
			
		end
	end
end

local function grow_shrink_size_width(elm)
	-- grow and shrink any child elements
	local is_row = elm.style.layout.dir == "row"
	
	local padding_space = is_row
		and elm.style.padding_inline[1] + elm.style.padding_inline[2]
		or elm.style.padding_block[1] + elm.style.padding_block[2]
	local remaining_space = elm.block.width - padding_space
	-- the remaining taken space is either
	-- the space consumed by all children if its on axis
	-- or the remaining space not taken up by the current child
	-- for off axis
	-- if remaining space is negative we need to shrink our 
	-- shrink children
	local grow_child_weight_total = 0
	for child in all(elm.children) do
		if is_row then
			remaining_space -= child.block.width
		end
		
		if child.style.sizing.width.tag == "Grow" then
			grow_child_weight_total += child.style.sizing.width.v
		end
	end
	
	local total_gap = #elm.children > 0
		and (#elm.children - 1) * elm.style.child_gap
		or 0
	if is_row then remaining_space -= total_gap end
	local shrinkables = {}
	for child in all(elm.children) do
		if is_row then
			if remaining_space > 0 and child.style.sizing.width.tag == "Grow" then
				local child_grow_entitlement = 
					child.style.sizing.width.v / grow_child_weight_total
				child.block.width += remaining_space * child_grow_entitlement
			end
			
			if child.style.sizing.width.tag == "Shrink"
				or child.style.sizing.width.tag == "Fit" then
				add(shrinkables, child)
			end
		else 
			-- grow the child to fill the remaining off axis space
			child.block.width = remaining_space
		end
	end
	
	-- handle shrinking
	local EPS = 0.01

	while remaining_space < -EPS and #shrinkables > 0 do
	  local largest, second_largest = 0, 0
	
	  for child in all(shrinkables) do
	    local w = child.block.width
	    if abs(w - largest) > EPS then
	      if w > largest then
	        second_largest = largest
	        largest = w
	      else
	        second_largest = max(second_largest, w)
	      end
	    end
	  end
	
	  -- both values are negative: take the smaller step
	  local space_to_add = max(
	    second_largest - largest,
	    remaining_space / #shrinkables
	  )
	
	  for i = #shrinkables, 1, -1 do
	    local b = shrinkables[i].block
	    if abs(b.width - largest) <= EPS then
	      local prev = b.width
	      b.width += space_to_add
	      if b.width <= b.min_width then
	        b.width = b.min_width
	        deli(shrinkables, i)
	      end
	      remaining_space -= (b.width - prev)
	    end
	  end
	end
	
	-- children's widths are now final, so size their children
	for child in all(elm.children) do
		grow_shrink_size_width(child)
	end
end

local space_w = 6
local function wrap_text(elm)
	-- we now know the width that our text is allowed to inhabit
	-- now we need to create lines that fit inside that width
	if elm.name == "text" then
		local wrap_max = elm.parent.block.width
			- (elm.parent.style.padding_inline[1]
			+ elm.parent.style.padding_inline[2])
		
		elm.lines = {}
		if wrap_max > elm.block.width then
			-- no need to wrap, place all the content into a line	
			add(elm.lines, {
				content = elm.content
			})
			elm.block.height = 10
			elm.block.min_height = 10
			elm.parent.block.min_height = 10
		else
			local current_line = ""
			local current_line_size = 0
			local raw_lines = split(elm.content, "\n")
			for rl in all(raw_lines) do
				local raw_words = split(rl, " ")
				for word in all(raw_words) do
					local size = size_word(word) 
					if current_line_size + size + space_w > wrap_max and 
					current_line_size != 0 then
						add(elm.lines, { content = current_line })
						current_line = ""
						current_line_size = 0
					end
					if current_line_size == 0 then
						current_line_size += size
						current_line = word
					else 
						current_line_size += size + space_w
						current_line = current_line .. " " .. word
					end
				end
				if current_line_size > 0 then
					add(elm.lines, { content = current_line })
				end
			end
			elm.block.min_height = #elm.lines * 10
			elm.parent.block.min_height = max(elm.parent.block.min_height, elm.block.min_height) 
		end
	end
	
	for child in all(elm.children) do
		wrap_text(child)
	end
end

local function fit_size_height(elm)
	local is_row = elm.style.layout.dir == "row"

	local child_acc = elm.style.padding_block[1]
	local max_child = 0
	for child in all(elm.children) do
		fit_size_height(child)
		if is_row then
			-- off axis, find biggest child height
			if child.block.height > max_child then
				max_child = child.block.height
			end
		else
			child_acc += child.block.height
		end
	end
	
	if elm.style.sizing.height.tag == "Fixed" then
		elm.block.height = elm.style.sizing.height.v
	else
		local total_gap = #elm.children > 0
			and (#elm.children - 1) * elm.style.child_gap
			or 0
		if is_row then
			elm.block.min_height = max(elm.style.padding_block[1] + 
				max_child + elm.style.padding_block[2], elm.block.min_height)
			elm.block.height = max(elm.style.padding_block[1] + 
				max_child + elm.style.padding_block[2], elm.block.min_height)
		else
			elm.block.min_height = max(child_acc + total_gap 
				+ elm.style.padding_block[2], elm.block.min_height)
			elm.block.height = max(child_acc + total_gap 
				+ elm.style.padding_block[2], elm.block.min_height)
		end
	end
end

local function grow_shrink_size_height(elm)
	-- for height, columns are on-axis and rows are off-axis
	local on_axis = elm.style.layout.dir == "column"

	-- height always uses the block padding, whatever the direction
	local padding_space = elm.style.padding_block[1] + elm.style.padding_block[2]
	local remaining_space = elm.block.height - padding_space

	local grow_child_weight_total = 0
	for child in all(elm.children) do
		if on_axis then
			remaining_space -= child.block.height
		end

		if child.style.sizing.height.tag == "Grow" then
			grow_child_weight_total += child.style.sizing.height.v
		end
	end

	local total_gap = #elm.children > 0
		and (#elm.children - 1) * elm.style.child_gap
		or 0
	if on_axis then remaining_space -= total_gap end

	local shrinkables = {}
	for child in all(elm.children) do
		local tag = child.style.sizing.height.tag
		if on_axis then
			if remaining_space > 0 and tag == "Grow" then
				local entitlement = child.style.sizing.height.v / grow_child_weight_total
				child.block.height += remaining_space * entitlement
			end

			if tag == "Shrink" or tag == "Fit" then
				add(shrinkables, child)
			end
		else
			-- off axis: remaining_space is the parent's inner height
			if tag == "Grow" then
				child.block.height = remaining_space
			elseif tag != "Fixed" then
				-- clamp down to the parent, but never below the child's min
				child.block.height = max(
					child.block.min_height,
					min(child.block.height, remaining_space)
				)
			end
		end
	end

	-- handle shrinking
	local EPS = 0.01

	while remaining_space < -EPS and #shrinkables > 0 do
		local largest, second_largest = 0, 0

		for child in all(shrinkables) do
			local h = child.block.height
			if abs(h - largest) > EPS then
				if h > largest then
					second_largest = largest
					largest = h
				else
					second_largest = max(second_largest, h)
				end
			end
		end

		-- both values are negative: take the smaller step
		local space_to_add = max(
			second_largest - largest,
			remaining_space / #shrinkables
		)

		for i = #shrinkables, 1, -1 do
			local b = shrinkables[i].block
			if abs(b.height - largest) <= EPS then
				local prev = b.height
				b.height += space_to_add
				if b.height <= b.min_height then
					b.height = b.min_height
					deli(shrinkables, i)
				end
				remaining_space -= (b.height - prev)
			end
		end
	end

	-- children's heights are now final, so size their children
	for child in all(elm.children) do
		grow_shrink_size_height(child)
	end
end

local function position(elm)
	-- compute the element position first
	if elm.parent == nil then
		elm.block.x = elm.style.margin_inline[1]
		elm.block.y = elm.style.margin_block[1]
	end
	
	local is_row = elm.style.layout.dir == "row"
	
	local on_axis_acc = is_row
		and elm.block.x + elm.style.padding_inline[1]
		or elm.block.y + elm.style.padding_block[1]
	local off_axis = is_row
		and elm.block.y + elm.style.padding_block[1]
		or elm.block.x + elm.style.padding_inline[1]
		
	if elm.name == "text" then
		-- we need to position all of the lines
		local y = 0
		foreach(elm.lines, function(line)
			line.x = elm.parent.block.x 
				+ elm.parent.style.padding_inline[1]
			line.y = elm.parent.block.y + (y * 10)
				+ elm.parent.style.padding_block[1]
			y += 1
		end)
	end 
		
	for child in all(elm.children) do
		child.block.x = is_row and on_axis_acc or off_axis
		child.block.y = not is_row and on_axis_acc or off_axis
		position(child)
		on_axis_acc += is_row
			and child.block.width + elm.style.child_gap 
			or child.block.height + elm.style.child_gap
	end
end

function circumflex_layout(elm)
	clean(elm)
	fit_size_width(elm)
	grow_shrink_size_width(elm)
	wrap_text(elm)
	fit_size_height(elm)
	grow_shrink_size_height(elm)
	position(elm)
end

function circumflex_elm(elm) 
	return {
		block = {
			x = 0,
			y = 0,
			width = 0,
			height = 0,
			min_width = 0,
			min_height = 0
		},
		style = {
			layout = {
				dir = elm.dir or "row"
			},
			sizing = {
				width = elm.width or Fit(),
				height = elm.height or Fit()
			},
			min_width = elm.min_width or 0,
			min_height = elm.min_height or 0,
			child_gap = elm.child_gap or 0,
			padding_inline = elm.padding_inline or {0, 0},
			padding_block = elm.padding_block or {0, 0},
			margin_inline = elm.margin_inline or {0, 0},
			margin_block = elm.margin_block or {0, 0},
			background_color = elm.background_color or nil,
			border_color = elm.border_color or nil,
			color = elm.color or 0
		},
		name = elm.name or "",
		content = elm.content or "",
		parent = nil,
		children = {},
		attributes = {},
		set_children = function(self, children)
			self.children = children
			for child in all(self.children) do
				child.parent = self
			end
		end
	}
end