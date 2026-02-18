-- A element item individual system elements
--
-- @classmod SystemElement
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local JsonExport = require ("kpcrew.json_pretty_print")

local ngSystemElement = {}

--- Instantiate a new Element
-- @param string name  
-- @param string title 
-- @param string elementnode from json 
-- @return SystemElement - the created SystemElement object
function ngSystemElement:new(name, title, elementNode)
    ngSystemElement.__index = ngSystemElement
    local obj = {}
    setmetatable(obj, ngSystemElement)

	obj.className = "SystemElement"
	
    obj.name = name
	obj.title = title
	obj.elementNode = elementNode
	
	print("+ "..obj.className.." {"..obj.name.."}")

    return obj
end

--- get classname
-- @return string className
function ngSystemElement:getClassName() return self.className end

--- get name string
-- @return string - name text
function ngSystemElement:getName() return self.name end

--- set name
-- @param string name
function ngSystemElement:setName(name) self.name = name end

--- get name string
-- @return string - name text
function ngSystemElement:getTitle() return self.title end

--- set name
-- @param string name
function ngSystemElement:setTitle(title) self.title = title end

--- set element node
-- @param table elementNode
function ngSystemElement:setElementNode(elementNode) self.elementNode = elementNode end

--- get element node
-- @return table elementNode
function ngSystemElement:getElementNode() return self.elementNode end

function ngSystemElement:render()
	if self ~= nil then
		
		ng_imgui_out_text(color_white,"Name/Title:") imgui.SameLine() ng_imgui_out_text(color_white, self.name .."/"..self.title)
		if self.elementNode.type ~= nil then 		
			ng_imgui_out_text(color_white,"Type:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.type) 
		end
		ng_imgui_out_text(color_white,"Actions:") imgui.SameLine() ng_imgui_out_text(color_white, JsonExport:pretty_print(self.elementNode.acts))
		if self.elementNode.dref ~= nil then 		
			ng_imgui_out_text(color_white,"Dref:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.dref) 
		end
		if self.elementNode.indx ~= nil then 		
			ng_imgui_out_text(color_white,"Indx:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.indx)
		end
	end
end


return ngSystemElement