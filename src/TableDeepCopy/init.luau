local function tableDeepCopy<T>(t: T): T
	assert(typeof(t) == "table", "argument must be table type. ")

	local tCopy = {}

	for k, v in pairs(t) do
		if type(v) == "table" then
			tCopy[k] = tableDeepCopy(v)
		else
			tCopy[k] = v
		end
	end

	return tCopy
end

return tableDeepCopy