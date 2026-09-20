-- Base class for Aircraft Assignments
-- An assignment associates SOP, Systems and Preferences to an aircraft on load
--
-- @classmod ngAircraftAssignments
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local Assignment = require("kpcrew.Addon.Assignments.Assignment")
local JsonExport = require ("kpcrew.json_pretty_print")

local ngAircraftAssignments = {}

--- Instantiate a new Assignment set
-- @param string title - Name of the Assignments set
-- @param string filePath - Path of the assignments json to load
-- @return self object
function ngAircraftAssignments:new(title, filePath)
    ngAircraftAssignments.__index = ngAircraftAssignments
    local obj = {}
    setmetatable(obj, ngAircraftAssignments)

	obj.className = "AircraftAssignments"
	
    obj.title = title
	obj.filePath = filePath
	
	obj.assignments = {} -- all associated flows
	
	dprint("+ "..obj.className.." {"..obj.title.."}")
	
    return obj
end

--- get classname
-- @return string classname
function ngAircraftAssignments:getClassName() return self.className end

--- Get title of Assignments
-- @return string - title of Systems
function ngAircraftAssignments:getTitle() return self.title end

--- Set the title of the Systems
-- @param string title - title for Systems
function ngAircraftAssignments:setTitle(title) self.title = title end

--- Add a system assignment to Systems
-- @param AircraftAssignment assignment - assignment to be appended
function ngAircraftAssignments:appendAssignment(assignment) table.insert(self.assignments,assignment) end

--- Insert a assignment at specific position
-- @param AircraftAssignment assignment - assignment to be inserted
-- @param int index - index at which to add
function ngAircraftAssignments:insertAssignment(assignment, index) table.insert(self.assignments,index,assignment) end
	
--- Get a specific assignment based on index
-- @param int index - assignments index in table
-- @return AircraftAssignment - assignment at index
function ngAircraftAssignments:getAssignment(index) return self.assignments[index] end

--- Get a all assignments
-- @return AircraftAssignment - assignment at index
function ngAircraftAssignments:getAssignments() return self.assignments end

--- Set assignments table
-- @param AircraftAssignment[] to set
function ngAircraftAssignments:setAssignments(assignments) self.assignments = assignments end

--- Find a assignment element object in all groups
-- key to look for
-- @param string inkey Key of system element to find
-- @return AircraftAssignment found or nil
function ngAircraftAssignments:find(inkey)

	for _,catnode in pairs(self.assignments) do
		local assignments = catnode:getAssignments()
		if assignments ~= nil then
			for _,assignmentnode in pairs(assignments) do
				local elements = systemnode:getElements()
				if elements ~= nil then
					for _,elemnode in pairs(elements) do
						if elemnode:getName() == inkey then
							return elemnode
						end
					end
				end
			end
		end
	end
	return nil
end

--- Find a assignment object in all assignments
-- key contains 
-- @param string inkey Key of assignment element to find
-- @return assignment found or nil
function ngAircraftAssignments:findAssignment(planeicao,planetail)

	local foundnode = nil
	local dfltnode = nil

	print("ICAO/TAILNUM:"..planeicao.."/"..planetail.."/")
	for _,assignnode in pairs(self.assignments) do
	
		local aplaneicao = assignnode:getPlaneicao()
		local aplanetail = assignnode:getPlanetailnum()
		print("ASSIGN ICAO/TAILNUM:"..aplaneicao.."/"..aplanetail.."/")
		
		if aplaneicao == "DFLT" then
			dfltnode = assignnode
		end
		
		if aplaneicao == "" and aplanetail ~= "" then
			if planetail == aplanetail then
				foundnode = assignnode
				print("tailonly "..foundnode.name)
				return foundnode
			end
		elseif aplaneicao ~= "" and aplanetail == "" then
			--search for icao only
			if aplaneicao == planeicao then
				foundnode = assignnode
				print("icaoonly "..foundnode.name)
				return foundnode
			end
		elseif aplaneicao ~= "" and aplanetail ~= "" then
			-- search for both
			if aplaneicao == planeicao and planetail == aplanetail then
				foundnode = assignnode
				print("both "..foundnode.name)
				return foundnode
			end
		end
	end

	return dfltnode
end

--- Load Systems
function ngAircraftAssignments:load()
	
	if ng_file_exists(self.filePath) then
		
		local json = require "kpcrew.json"
		local file = io.open(self.filePath, "r")
		local jsonstr = ""
		for line in file:lines() do jsonstr = jsonstr .. line end
		file:close()
		local assignments = json.parse(jsonstr)

		for assignmentkey,assignmentnode in pairs(assignments.acftselect.addons) do
		    local assignment = Assignment:new(assignmentnode.name,assignmentnode.planeicao, assignmentnode.planetailnum, assignmentnode.settings)
			self:appendAssignment(assignment)
		end
		
	end
end

return ngAircraftAssignments