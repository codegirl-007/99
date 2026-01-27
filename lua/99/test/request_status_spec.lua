-- luacheck: globals describe it assert
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
local RequestStatus = require("99.ops.request_status")
local Mark = require("99.ops.marks")
local test_utils = require("99.test.test_utils")
local Point = require("99.geo").Point

describe("request_status", function()
  it("setting lines and status line", function()
    local buffer =
      test_utils.create_file({ "", "function foo() end" }, "lua", 1, 1)
    local point = Point:new(1, 1)
    local mark = Mark.mark_point(buffer, point)
    local status = RequestStatus.new(2000000, 3, "TITLE", mark)
    eq({ "⠙ TITLE" }, status:get())

    status:push("foo")
    status:push("bar")

    eq({ "⠙ TITLE", "foo", "bar" }, status:get())

    status:push("baz")

    eq({ "⠙ TITLE", "bar", "baz" }, status:get())
  end)
end)
