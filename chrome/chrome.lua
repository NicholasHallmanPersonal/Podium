--[[pod_format="raw",created="2026-09-28 12:06:29",modified="2026-10-03 01:25:50",prog="bbs://strawberry_src-15.p64",revision=87,xstickers={}]]

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
  		y = 15
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
	    	printh("!!!RESIZE!!! " .. msg.width .. " " .. msg.height)
	    	self.frame.width = msg.width
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
		self.url_bar:set_text(podkit["location"])
		self.gui:attach_button{
			x=2,y=1,bgcol=frame_color,fgcol=7,label="\22"
		}
		self.gui:attach_button{
			x=2+15+2,y=1,bgcol=frame_color,fgcol=7,label="\23"
		}
 	end,
 	update = function(self)
 		self.url_bar.width = self.window_size["width"] - 36 - 1
 		printh("url bar width " .. self.url_bar.width)
		self.gui:update_all()
 	end,
 	draw = function(self)
		cls(7)
		rectfill(0, 0, self.window_size.width - 1, 14, theme"window_frame")
	
		self.gui:draw_all()
	end
} 
