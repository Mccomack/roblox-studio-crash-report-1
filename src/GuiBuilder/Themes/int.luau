local module = {}
local Themes = {}

for i, v in pairs(script:GetChildren()) do
	Themes[v.Name] = require(v)
end

return Themes
