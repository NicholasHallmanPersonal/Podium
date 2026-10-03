--[[pod_format="raw",created="2026-09-28 12:06:29",modified="2026-10-03 19:45:06",prog="bbs://strawberry_src-15.p64",revision=168,xstickers={}]]

local window_size = {}

local gui = create_gui()
local url_bar

chrome = {
  	gui = create_gui(),
  	url_bar,
  	window_size = {},
  	frame = {
  		width = 0,
  		height = 0,
  		x = 0,
  		y = 15,
		scroll = 0,
		scroll_offset = 0
  	},
  	init = function(self) 
		window {
  			width = 300,
  			height = 200,
  			resizable = true,
  			title = "Podium"
  		}

		self.window_size.width = get_display():width()
		self.window_size.height = get_display():height()
		
		self.frame.width = get_display():width()
		self.frame.height = get_display():height() - 15
	
  		on_event("resize", function (msg)
    		self.window_size.width = msg.width
	    	self.window_size.height = msg.height
	    	self.frame.width = msg.width - 6 -- scroll bar gutter
			self.frame.height = msg.height
  		end)

		self.url_bar = self.gui:attach_text_editor{
			x=36, y=1, bgcol=7, fgcol=0, 
			width=self.window_size["width"] - 36 - 1, height=13,
			key_callback = {
				["enter"] = function(self, k)
					podkit["location"] = chrome.url_bar:get_text()
				end
			}
		}
		local frame_color = theme"window_frame"
		local off_frame_color = theme"win_frame"
		local btn_color = off_frame_color << 8 | frame_color  
		self.url_bar:set_text(podkit["location"])
		

		self.gui:attach_button{
			x=2,y=1,bgcol=btn_color,fgcol=0x0707,label="\22"
		}
		self.gui:attach_button{
			x=2+15+2,y=1,bgcol=btn_color,fgcol=0x0707,label="\23"
		}
 	end,
 	update = function(self)
 		self.url_bar.width = self.window_size["width"] - 36 - 1
		self.gui:update_all()
 	end,
 	draw = function(self, body_height)
		rectfill(0, 0, self.window_size.width - 1, 14, theme"window_frame")
		
		self.gui:draw_all()
		
		if body_height + 14 > self.frame.height then
			-- need the scroll gutter
			rectfill(self.window_size.width - 6, 15, 
				self.window_size.width, self.window_size.height, 
				theme"desktop0"
			)
			-- scroll indicator
			-- min height = 20, max height = self.frame.height - 10
			-- 
			local scroll_bar_height = max(20, self.frame.height - 10 - self.frame.scroll_offset)
			local scroll_position = ((self.frame.scroll / self.frame.scroll_offset) 
				* (self.frame.height - scroll_bar_height - self.frame.y)) 
			rectfill( self.window_size.width - 5, self.frame.y + scroll_position,
				self.window_size.width - 2, self.frame.y + scroll_position + scroll_bar_height,
				theme"desktop1"
			)
		end 
	end
} 
