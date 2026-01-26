# Request history + info changes

- Step 1: Add request history data structures and helpers on `_99_State` in `lua/99/init.lua` so you can store running + previous requests, mark completion, clear previous entries, and remove specific requests.
  ```lua
  --- @class _99.RequestEntry
  --- @field id number
  --- @field operation string
  --- @field status "running" | "success" | "failed" | "cancelled"
  --- @field filename string
  --- @field lnum number
  --- @field col number
  --- @field started_at number
  
  local function create_99_state()
    return {
      ...
      __request_history = {},
      __request_by_id = {},
    }
  end
  
  function _99_State:track_request(context)
    local point = context.range and context.range.start or Point:from_cursor()
    local entry = {
      id = context.xid,
      operation = context.operation or "request",
      status = "running",
      filename = context.full_path,
      lnum = point.row,
      col = point.col,
      started_at = time.now(),
    }
    table.insert(self.__request_history, entry)
    self.__request_by_id[entry.id] = entry
    return entry
  end
  
  function _99_State:finish_request(id, status)
    local entry = self.__request_by_id[id]
    if entry then
      entry.status = status
    end
  end
  
  function _99_State:remove_request(id)
    for i, entry in ipairs(self.__request_history) do
      if entry.id == id then
        table.remove(self.__request_history, i)
        break
      end
    end
    self.__request_by_id[id] = nil
  end
  
  function _99_State:previous_request_count()
    local count = 0
    for _, entry in ipairs(self.__request_history) do
      if entry.status ~= "running" then
        count = count + 1
      end
    end
    return count
  end
  
  function _99_State:clear_previous_requests()
    local keep = {}
    for _, entry in ipairs(self.__request_history) do
      if entry.status == "running" then
        table.insert(keep, entry)
      else
        self.__request_by_id[entry.id] = nil
      end
    end
    self.__request_history = keep
  end
  ```
- Step 2: Capture the operation name on each context so requests are labeled consistently.
  ```lua
  local function get_context(operation_name)
    _99_state:refresh_rules()
    local trace_id = get_id()
    local context = RequestContext.from_current_buffer(_99_state, trace_id)
    context.operation = operation_name
    context.logger:debug("99 Request", "method", operation_name)
    return context
  end
  ```
- Step 3: Track request start/completion in `lua/99/request/init.lua` so history stays in sync for every request.
  ```lua
  function Request:start(observer)
    self.context._99:track_request(self.context)
    observer = observer or DevNullObserver
    local on_complete = observer.on_complete
    observer.on_complete = function(status, res)
      self.context._99:finish_request(self.context.xid, status)
      on_complete(status, res)
    end
    ...
  end
  ```
- Step 4: Store request ids alongside active cleanups and drop stopped requests when `stop_all_requests` runs.
  ```lua
  function _99_State:add_active_request(clean_up, request_id)
    _active_request_id = _active_request_id + 1
    self.__active_requests[_active_request_id] = {
      clean_up = clean_up,
      request_id = request_id,
    }
    return _active_request_id
  end
  ```
  ```lua
  -- lua/99/ops/clean-up.lua
  request_id = context._99:add_active_request(clean_up, context.xid)
  ```
  ```lua
  function _99.stop_all_requests()
    for _, active in pairs(_99_state.__active_requests) do
      _99_state:remove_request(active.request_id)
      active.clean_up()
    end
    _99_state.__active_requests = {}
  end
  ```
- Step 5: Add the public operations to send the list to quickfix and clear previous requests.
  ```lua
  function _99.previous_requests_to_qfix()
    local items = {}
    for _, entry in ipairs(_99_state.__request_history) do
      table.insert(items, {
        filename = entry.filename,
        lnum = entry.lnum,
        col = entry.col,
        text = string.format("[%s] %s", entry.status, entry.operation),
      })
    end
    vim.fn.setqflist({}, "r", { title = "99 Requests", items = items })
    vim.cmd("copen")
  end
  
  function _99.clear_previous_requests()
    _99_state:clear_previous_requests()
  end
  ```
- Step 6: Update `.info()` to include previous request count and rule names (not paths).
  ```lua
  function _99.info()
    local info = {}
    _99_state:refresh_rules()
    table.insert(
      info,
      string.format("Previous Requests: %d", _99_state:previous_request_count())
    )
    table.insert(info, string.format("cursor rules(%d):", #_99_state.rules.cursor))
    for _, rule in ipairs(_99_state.rules.cursor or {}) do
      table.insert(info, string.format("* %s", rule.name))
    end
    table.insert(info, string.format("custom rules(%d):", #_99_state.rules.custom))
    for _, rule in ipairs(_99_state.rules.custom or {}) do
      table.insert(info, string.format("* %s", rule.name))
    end
    Window.display_centered_message(info)
  end
  ```
