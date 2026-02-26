local M = {}

--- @param str string
---@param word_count number
---@return string[]
function M.split_with_count(str, word_count)
  local out = {}
  local words = vim.split(str, "%s+", { trimempty = true })

  local count = math.min(word_count, #words)
  for i = 1, count do
    table.insert(out, words[i])
  end

  return out
end

function M.copy(t)
  assert(type(t) == "table", "passed in non table into table")
  local out = {}
  for k, v in pairs(t) do
    out[k] = v
  end
  for i, v in ipairs(t) do
    out[i] = v
  end
  return out
end

--- @param dir string
--- @return string
function M.random_file(dir)
  return string.format("%s/99-%d", dir, math.floor(math.random() * 10000))
end

--- @param dir string
--- @param name string
--- @return string
function M.named_tmp_file(dir, name)
  return string.format("%s/99-%s", dir, name)
end

return M
