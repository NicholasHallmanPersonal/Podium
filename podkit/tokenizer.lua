--[[pod_format="raw",created="2026-09-30 23:40:21",modified="2026-10-07 12:08:54",revision=176,xstickers={}]]
--[[
Example content

$document
  $head
    $title "PodPage Name"
  $body
    $h1 "Hello World"
    $p "This is my pod page"
	 $div
	   $div
	     $p "deeply nested"
	 $img src="cool.png" alt-text="a cool picture"

]]

function s_to_ord(s)
	local o = ""
	for i = 1, #s, 1 do
		local c = sub(s, i, true)
		o = o .. " " ord(c)
	end
	return o
end

function is_whitespace(c)
	return ord(c) == 9 or ord(c) == 32
end

function is_alphabeta(c)
	local o = ord(c)
	if o >= 97 and o <= 122 then return true end
	if o >= 65 and o <= 90 then return true end
	if o == 64 then return true end
	return false
end

function is_dash(c)
	if c == "-" then return true end
	return false
end

function is_attr_char(c)
	if is_alphabeta(c) or is_dash(c) then return true end
	return false
end

function new_tokenizer()

	function INDENT() 
		return { token="indent" } end
	function DEDENT() 
		return { token="dedent" } end
	function TAG_NAME(v) 
		return { token="tag_name", value = v } end
	function ATTRIBUTE(n, v) 
		return { token="attr", name=n, value=v } end
	function STRING(s) 
		return { token="string", value=s } end
	
	local tokenizer = {
		content = nil,
		tokens = {},
		indent_match = nil,
		depth_count = 0,
		_i = 0
	}
	
	function tokenizer:start(content)
		self.content = content
		local char = self:next_char()
		while char != nil do
			-- decide what to do with the character
			local result
			if char == "$" then
				-- tag names always start with a $
				self:observe_tag_name()
			elseif char == "\n" then
				-- new line, read indentation
				self:observe_indentation()
			elseif char == "\"" then
				add(self.tokens, self:observe_string())
			elseif is_attr_char(char) then
				self:observe_attr()
			end
			char = self:next_char()
		end
	end
	
	function tokenizer:peek_char()
		return sub(self.content, self._i, true)
	end
	
	function tokenizer:next_char()
		self._i += 1
		if self._i > #self.content then return nil end
		return sub(self.content, self._i, true)
	end
	
	function tokenizer:observe_tag_name(i)
		local name = ""
		local char = self:next_char()
		while char != nil and char != " " and char != "\n" 
		and char != "\t" do
			name = name .. char
			char = self:next_char() 
		end
		if char == "\n" then self._i -= 1 end
		add(self.tokens, TAG_NAME(name))
	end
	
	function tokenizer:observe_indentation(i)
		local char = self:next_char()

		if is_whitespace(char) and self.indent_match == nil then
			-- we don't know what the indentation pattern looks
			-- like yet, capture it here
			printh("no pattern")
			local pattern = char
			char = self:next_char()
			while is_whitespace(char) do
				pattern = pattern .. char
				char = self:next_char()
			end
			self.indent_match = pattern
			self.depth_count += 1
			add(self.tokens, INDENT())
		elseif is_whitespace(char) then
			-- count number of times we see the indent pattern
			local match_count = 0
			while is_whitespace(char) do
				local ptrn_pos = 1
				local ptrn_char = 
				sub(self.indent_match, ptrn_pos, true)
				-- pattern matcher
				while ptrn_pos <= #self.indent_match
				and char == ptrn_char do
					ptrn_pos += 1
					if ptrn_pos > #self.indent_match then
						match_count += 1
					else 
						ptrn_char = 
							sub(self.indent_match, ptrn_pos, true)
					end
					char = self:next_char()
				end
			end
			-- we now know how many times the pattern was matched
			local change = match_count - self.depth_count
			if change > 0 then 
				for i = 1, change, 1 do
					add(self.tokens, INDENT())
				end
			elseif change < 0 then
				for i = 1, abs(change), 1 do
					add(self.tokens, DEDENT())
				end
			end
			self.depth_count = match_count
		end
		-- the token after \n isn't whitespace 
		-- and the token after we parse isn't whitespace
		-- rewind
		self._i -= 1
	end
	
	function tokenizer:observe_string()
		local char = self:next_char()
		local are_esc = false
		local value = ""
		local done = false
		while not done do
			if are_esc then
				value = value .. char
				are_esc = false
			else 
				local last_value = sub(value, #value, true)
				if char == "\\" then are_esc = true
				elseif char == "\"" then done = true
				elseif char == "\n" then value = value .. " " -- ignore
				elseif char == "\r" then -- ignore
				elseif char == " " and last_value != " " then value ..= " "
				elseif char == " " then --ignore
				elseif char == "\t" and last_value != " " then value ..= " "
				elseif char == "\t" then --ignore
				else value = value .. char end
			end
			char = self:next_char()
		end
		if char == "\n" then self._i -= 1 end
		return STRING(value)
	end
	
	function tokenizer:observe_attr()
		local char = self:peek_char()
		local attr = ""
		-- continue until we see a space or an =
		while char != "=" and char != " " do
			attr = attr .. char
			char = self:next_char()
		end
		
		if char == "=" then
			-- there's a attr value
			char = self:next_char()
			assert(char == "\"", "attribute names must start with a \" ")
			add(self.tokens, ATTRIBUTE(
				attr, 
				self:observe_string()
			))
		elseif char == " " then
			-- it's a value less attribute!
			add(self.tokens, ATTRIBUTE(
				attr, 
				true
			))
		end
	end
	
	return tokenizer
end
