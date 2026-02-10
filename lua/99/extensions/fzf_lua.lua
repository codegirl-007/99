local _99 = require("99")

local M = {}

-- move the current value to the top of the list so fzf opens with it focused
--- @param list string[]
--- @param current string
--- @return string[]
local function promote_current(list, current)
  local result = {}
  local rest = {}
  for _, item in ipairs(list) do
    if item == current then
      table.insert(result, 1, item)
    else
      table.insert(rest, item)
    end
  end
  for _, item in ipairs(rest) do
    table.insert(result, item)
  end
  return result
end

--- @param provider _99.Providers.BaseProvider?
function M.select_model(provider)
  provider = provider or _99.get_provider()

  provider.fetch_models(function(models, err)
    if err then
      vim.notify("99: " .. err, vim.log.levels.ERROR)
      return
    end
    if not models or #models == 0 then
      vim.notify("99: No models available", vim.log.levels.WARN)
      return
    end

    local ok, fzf = pcall(require, "fzf-lua")
    if not ok then
      vim.notify(
        "99: fzf-lua is required for this extension",
        vim.log.levels.ERROR
      )
      return
    end

    local current = _99.get_model()

    fzf.fzf_exec(promote_current(models, current), {
      prompt = "99: Select Model (current: " .. current .. ")> ",
      actions = {
        ["enter"] = function(selected)
          if not selected or #selected == 0 then
            return
          end
          _99.set_model(selected[1])
          vim.notify("99: Model set to " .. selected[1])
        end,
      },
    })
  end)
end

function M.select_provider()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.notify(
      "99: fzf-lua is required for this extension",
      vim.log.levels.ERROR
    )
    return
  end

  local providers = _99.Providers
  local names = {}
  local lookup = {}
  for name, provider in pairs(providers) do
    table.insert(names, name)
    lookup[name] = provider
  end
  table.sort(names)

  local current = _99.get_provider()._get_provider_name()

  fzf.fzf_exec(promote_current(names, current), {
    prompt = "99: Select Provider (current: " .. current .. ")> ",
    actions = {
      ["enter"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local chosen = lookup[selected[1]]
        _99.set_provider(chosen)
        vim.notify(
          "99: Provider set to "
            .. selected[1]
            .. " (model: "
            .. _99.get_model()
            .. ")"
        )
      end,
    },
  })
end

return M
