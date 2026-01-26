local M = {}

--- @param path string
--- @return string
local function normalize_path(path)
  if path:sub(1, 1) == "/" then
    return path
  end
  if path:sub(1, 1) == "~" then
    return vim.fn.expand(path)
  end
  local cwd = vim.fs.joinpath(vim.uv.cwd(), path)
  return cwd
end

--- The skills for most people look like the following
--- /path/to/dir/<name>/SKILL.md
---
--- this will parse those out and return the Agents.Rule for each
--- The name of the agent rule will be the matching folder
--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls_skill_pattern(dir)
  local current_dir = normalize_path(dir)
  local glob = vim.fs.joinpath(current_dir, "/*/SKILL.md")
  local files = vim.fn.glob(glob, false, true)
  local rules = {}

  print("Globbing", vim.inspect(glob))
  for _, file in ipairs(files) do
    local folder_name = vim.fn.fnamemodify(file, ":h:t")
    table.insert(rules, {
      name = folder_name,
      path = file,
    })
  end

  return rules
end

print(vim.inspect(M.ls_skill_pattern("~/personal/skills/skills")))

--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls(dir)
  local current_dir = normalize_path(dir)
  local glob = vim.fs.joinpath(current_dir, "/*.{mdc,md}")
  local files = vim.fn.glob(glob, false, true)
  local rules = {}

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t:r")
    table.insert(rules, {
      name = filename,
      path = file,
    })
  end

  return rules
end

--- @param file string
--- @param count? number
--- @return string
function M.head(file, count)
  count = count or 5
  local fd = vim.uv.fs_open(file, "r", 438)
  if not fd then
    return ""
  end

  local stat = vim.uv.fs_fstat(fd)
  if not stat then
    vim.uv.fs_close(fd)
    return ""
  end

  local data = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)

  if not data then
    return ""
  end

  local lines = {}
  for line in data:gmatch("([^\n]*)\n?") do
    if count == 0 then
      break
    end
    count = count - 1
    table.insert(lines, line)
  end

  return table.concat(lines, "\n")
end

return M
