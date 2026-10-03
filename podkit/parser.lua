--[[pod_format="raw",created="2026-09-30 00:00:12",modified="2026-10-03 00:12:46",revision=107,xstickers={}]]
include "./podkit/tokenizer.lua"
include "./ui/lib.lua"
include "./podkit/styler.lua"

function debug_tokens(tokens)
	-- should have tokens
	for token in all(tokens) do
		printh("type " .. token.token)
		if token.value != nil and type(token.value) != "table" then
			printh("  value " .. token.value)
		end 
		if token.name != nil then 
			printh("  name " .. token.name)
		end
		if type(token.value) == "table" then
			printh("  attr value " .. token.value.value)
		end
	end
end

function new_parser()
	local parser = {
		tokenizer = new_tokenizer()
	}
	
	function parser:parse(content)
		self.tokenizer:start(content)
		local tokens = self.tokenizer.tokens
		assert(#tokens > 0, "Empty content")
		debug_tokens( tokens )
		local cur_elm = nil
		local root = circumflex_elm{ name="root" }
		local body = nil
		local parent_stack = {}
		parent_stack[1] = root
		local styler = new_styler()
		for token in all(tokens) do
			if token.token == "tag_name" then
				-- create a new element 
				cur_elm = circumflex_elm{ name=token.value }
				cur_elm.parent = parent_stack[#parent_stack]
				add(parent_stack[#parent_stack].children, cur_elm)
				styler:style(cur_elm)
				-- record found body tag for ease of layout
				if cur_elm.name == "body" then body = cur_elm end
			elseif token.token == "attr" then
				-- add the attribute data to the element
				local attr_value = true
				if type(token.value) == "table" then
					attr_value = token.value.value
				end
				
				printh(" which is nil " .. 
					(cur_elm == nil and "true " or "false ") .. 
					(cur_elm.attributes == nil and "true " or "false ") )
				cur_elm.attributes[token.name] = attr_value 
			elseif token.token == "string" then
				-- new text element, child of the cur elm
				local text_elm = circumflex_elm{}
				text_elm.content = token.value
				text_elm.name = "text"
				add(cur_elm.children, text_elm)
				text_elm.parent = cur_elm
			elseif token.token == "indent" then
				-- cur element is a parent of the
				-- next element we are going to see
				add(parent_stack, cur_elm)
			elseif token.token == "dedent" then
				-- pop off parent stack to find true parent
				deli(parent_stack)
			end
		end
		
		return root, body
	end
	
	return parser
end