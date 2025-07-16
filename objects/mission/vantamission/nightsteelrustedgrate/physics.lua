require "/scripts/vec2.lua"

function init()
	self.materialSpaces = {}
	local metamaterial = "metamaterial:door"
	for i, space in ipairs(object.spaces()) do
		table.insert(self.materialSpaces, {space, metamaterial})
	end
	object.setMaterialSpaces(self.materialSpaces)
	script.setUpdateDelta(10)
	sb.logInfo("Material Spaces: %s", self.materialSpaces)
end
