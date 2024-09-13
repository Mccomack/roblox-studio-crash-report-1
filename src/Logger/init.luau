--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local tableDeepCopy = require(ReplicatedStorage.Utility.TableDeepCopy)

local funcs = {
	print = print;
	warn = warn;
	error = error;
}

export type LogType = "print"|"warn"|"error"

export type Log = {
	Timestamp: number;
	LogType: LogType;
	Log: string;
	Traceback: string;
}

export type Logs = {
	Name: string;
	Logs: {
		[number]: Log;
	};
}

local logHandler = Instance.new("BindableEvent")

logHandler.Event:Connect(function(name: string, logType: LogType, log: string, traceback)
	funcs[logType](`[{name}]: {log}\nTraceback: {traceback}`)
end)

return function(name: string)
	local logs: Logs = {
		Name = name,
		Logs = {},
	}

	local function Log(logType: LogType, log: string, forcedToPrintLog: boolean?)
		local traceback = debug.traceback("", 2)
		
		table.insert(logs.Logs, {
			Timestamp = os.clock(),
			LogType = logType,
			Log = log,
			Traceback = traceback
		})

		if forcedToPrintLog or RunService:IsStudio() then
			local traceback = (logType == "print") and "" or traceback
			
			logHandler:Fire(name, logType, log, traceback)
		end
	end

	local function GetAllLogs()
		return tableDeepCopy(logs.Logs)
	end

	return {
		Log = Log;
		GetAllLogs = GetAllLogs;
	}
end