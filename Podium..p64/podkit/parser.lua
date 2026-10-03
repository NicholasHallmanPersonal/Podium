--[[pod_format="raw",created="2026-09-30 00:00:12",modified="2026-10-01 12:02:51",revision=56,xstickers={}]]
include "./podkit/tokenizer.lua"

function new_parser()
	local parser = {
		tokenizer = new_tokenizer()
	}
	
	function parser:parse(content)
		self.tokenizer:start(content)
		-- should have tokens
		for token in all(self.tokenizer.tokens) do
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
	
	return parser
end