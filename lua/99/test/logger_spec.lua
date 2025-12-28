-- luacheck: globals describe it assert before_each after_each
local Logger = require("99.logger.logger")
local time = require("99.time")
local eq = assert.are.same

local now = 0
time.now = function()
    return now
end

--- @class _99.Test.Logger.RequestLogs
--- @field last_access number
--- @field logs table<string, any>

--- @param all_logs table<number, _99.Logger.RequestLogs>
--- @return _99.Test.Logger.RequestLogs
local function l(all_logs)
    local out = {}
    for k, request in pairs(all_logs) do
        out[k] = {
            last_access = request.last_access,
            logs = {},
        }

        for _, log_line in ipairs(request.logs) do
            table.insert(out[k].logs, vim.json.decode(log_line))
        end
    end
    return out
end

describe("Logger", function()

    after_each(function()
        Logger.reset()
        now = 0
        Logger.set_max_cached_requests(2)
    end)

    it("no caching of non ID'd logs.  Global logs", function()
        eq({}, Logger.logs())

        local ok = pcall(Logger.debug, Logger, "test log")
        eq({}, Logger.logs())
        eq(ok, false)
    end)

    it("cache logs, keep max count", function()
        eq({}, Logger.logs())
        local logger = Logger:set_id(69)

        logger:debug("test log")

        eq({
            [69] = {
                last_access = 0,
                logs = {
                    {level = "DEBUG", id = 69, msg = "test log"},
                },
            }
        }, l(Logger.logs()))

        local logger2 = logger:set_id(420)
        now = 1000
        logger2:error("error log")

        eq({
            [69] = {
                last_access = 0,
                logs = {
                    {level = "DEBUG", id = 69, msg = "test log"},
                },
            },
            [420] = {
                last_access = 1000,
                logs = {
                    {level = "ERROR", id = 420, msg = "error log"},
                },
            },
        }, l(Logger.logs()))

        now = 1001
        logger:warn("warn log")

        eq({
            [69] = {
                last_access = 1001,
                logs = {
                    {level = "DEBUG", id = 69, msg = "test log"},
                    {level = "WARN", id = 69, msg = "warn log"},
                },
            },
            [420] = {
                last_access = 1000,
                logs = {
                    {level = "ERROR", id = 420, msg = "error log"},
                },
            },
        }, l(Logger.logs()))

        local logger3 = logger:set_id(1337)
        now = 1002
        logger3:info("info log")

        eq({
            [69] = {
                last_access = 1001,
                logs = {
                    {level = "DEBUG", id = 69, msg = "test log"},
                    {level = "WARN", id = 69, msg = "warn log"},
                },
            },
            [1337] = {
                last_access = 1002,
                logs = {
                    {level = "INFO", id = 1337, msg = "info log"},
                },
            },
        }, l(Logger.logs()))

    end)

end)
