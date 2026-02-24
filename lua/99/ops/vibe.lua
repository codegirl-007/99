local make_prompt = require("99.ops.make-prompt")
local CleanUp = require("99.ops.clean-up")

local make_clean_up = CleanUp.make_clean_up
local make_observer = CleanUp.make_observer

--- @class _99.Search.Result
--- @field filename string
--- @field lnum number
--- @field col number
--- @field text string

--- @param context _99.Prompt
---@param opts _99.ops.SearchOpts
local function vibe(context, opts)
  opts = opts or {}

  local logger = context.logger:set_area("vibe")
  logger:debug("vibe", "with opts", opts.additional_prompt)

  local clean_up = make_clean_up(function()
    context:stop()
  end)

  local prompt, refs =
    make_prompt(context, context._99.prompts.prompts.vibe(), opts)

  context:add_prompt_content(prompt)
  context:add_references(refs)
  context:add_clean_up(clean_up)

  --- TODO: part of the context request clean up there needs to be a refactoring of
  --- make observer... it really should just be within the context observer creation.
  --- same with cleanup.. that should just be clean_ups from context, instead of a
  --- once cleanup function wrapper.
  ---
  --- i think an interface, CleanUpI could be something that is worth it :)
  context:start_request(make_observer(clean_up, function(status, response)
    if status == "cancelled" then
      logger:debug("request cancelled for search")
    elseif status == "failed" then
      logger:error(
        "request failed for search",
        "error response",
        response or "no response provided"
      )
    elseif status == "success" then
      -- create_search_locations(context, response)
      -- need to parse out everything so i we can qfix list
      print("done", response)
    end
  end))
end
return vibe
