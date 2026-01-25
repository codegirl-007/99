-- luacheck: globals describe it assert
local eq = assert.are.same
local Providers = require("99.providers")

describe("providers", function()
  describe("OpenCodeProvider", function()
    it("builds correct command with model", function()
      local request = { context = { model = "anthropic/claude-sonnet-4-5" } }
      local cmd =
        Providers.OpenCodeProvider._build_command(nil, "test query", request)
      eq(
        { "opencode", "run", "-m", "anthropic/claude-sonnet-4-5", "test query" },
        cmd
      )
    end)
  end)

  describe("ClaudeCodeProvider", function()
    it("builds correct command with model", function()
      local request = { context = { model = "anthropic/claude-sonnet-4-5" } }
      local cmd =
        Providers.ClaudeCodeProvider._build_command(nil, "test query", request)
      eq({
        "claude",
        "--dangerously-skip-permissions",
        "--model",
        "anthropic/claude-sonnet-4-5",
        "--print",
        "test query",
      }, cmd)
    end)
  end)

  describe("CursorAgentProvider", function()
    it("builds correct command with model", function()
      local request = { context = { model = "anthropic/claude-sonnet-4-5" } }
      local cmd =
        Providers.CursorAgentProvider._build_command(nil, "test query", request)
      eq({
        "cursor-agent",
        "--model",
        "anthropic/claude-sonnet-4-5",
        "--print",
        "test query",
      }, cmd)
    end)
  end)

  describe("provider integration", function()
    it("can be set as provider override", function()
      local _99 = require("99")

      _99.setup({ provider = Providers.ClaudeCodeProvider })
      local state = _99.__get_state()
      eq(Providers.ClaudeCodeProvider, state.provider_override)
    end)
  end)

  describe("BaseProvider", function()
    it("all providers have make_request", function()
      eq("function", type(Providers.OpenCodeProvider.make_request))
      eq("function", type(Providers.ClaudeCodeProvider.make_request))
      eq("function", type(Providers.CursorAgentProvider.make_request))
    end)
  end)
end)
