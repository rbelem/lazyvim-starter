-- devbox.nvim -- devbox-managed tools inside Neovim
--
-- Detects devbox.json in project roots, runs `devbox shellenv`, injects vars
-- into vim.env. LSP servers inherit PATH and find mvn/java/go without global
-- installs.
--
-- sync strategy (default): essential for LSP -- env must be set BEFORE the
-- server starts. Cache makes the rest of the session instant.
-- async strategy: non-blocking, but LSP may start without devbox PATH.
--
-- Minimal usage:
--   { "devbox-nvim", dir = "~/.config/nvim/lua/devbox" }
--
-- With options:
--   {
--     "devbox-nvim",
--     dir = "~/.config/nvim/lua/devbox",
--     opts = { silent = true, strategy = "async" },
--   }

---@class devbox.Env
---@field vars table<string, string>
---@field project_root string
---@field path string

local config = require("devbox.config")

local Devbox = {}

---@type table<string, devbox.Env>
local env_cache = {}
---@type table<string, string>
local env_snapshot = {}
---@type string?
local active_root = nil
---@type boolean
local did_setup = false

---@param t table
---@return integer
local function tbl_count(t)
  local c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  return c
end

---@param opts? devbox.Config
function Devbox.setup(opts)
  if did_setup then
    return
  end
  did_setup = true

  config.setup(opts)
  local cfg = config.options

  if cfg.auto_activate then
    local grp = vim.api.nvim_create_augroup("devbox_nvim", { clear = true })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = grp,
      desc = "[devbox] activate",
      callback = function(args)
        if Devbox.is_active() then
          return
        end
        local buf_dir = vim.fn.expand(("#%d:p:h"):format(args.buf))
        Devbox.activate(buf_dir)
      end,
    })

    vim.api.nvim_create_autocmd("DirChanged", {
      group = grp,
      desc = "[devbox] re-check",
      callback = function()
        Devbox.deactivate()
        Devbox.activate()
      end,
    })
  end

  if cfg.lsp and cfg.lsp.inject_env then
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("devbox_nvim_lsp", { clear = true }),
      desc = "[devbox] inject PATH into LSP client",
      callback = function(args)
        if not Devbox.is_active() then
          return
        end
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          Devbox._inject_path(client)
        end
      end,
    })
  end

  vim.api.nvim_create_user_command("DevboxActivate", function()
    if not Devbox.activate() then
      vim.notify("[devbox] no devbox.json found", vim.log.levels.INFO)
    end
  end, { desc = "[devbox] activate devbox env" })

  vim.api.nvim_create_user_command("DevboxDeactivate", function()
    Devbox.deactivate()
  end, { desc = "[devbox] deactivate devbox env" })

  vim.api.nvim_create_user_command("DevboxStatus", function()
    if Devbox.is_active() then
      vim.notify("[devbox] active: " .. (Devbox.get_active_root() or "?"))
    else
      vim.notify("[devbox] inactive")
    end
  end, { desc = "[devbox] show status" })

  vim.api.nvim_create_user_command("DevboxClearCache", function()
    Devbox.clear_cache()
    vim.notify("[devbox] cache cleared")
  end, { desc = "[devbox] clear env cache" })
end

--- Walk up the directory tree looking for devbox.json
---@param dir? string Starting directory (defaults to current buffer's dir)
---@return string? Absolute project root path, or nil
function Devbox.find_root(dir)
  dir = dir or vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  local root
  if vim.fs.root then
    root = vim.fs.root(dir, "devbox.json")
  end
  if not root then
    local f = vim.fn.findfile("devbox.json", dir .. ";")
    if f ~= "" then
      root = vim.fn.fnamemodify(f --[[@as string]], ":p:h")
    end
  end
  return root
end

---@return boolean
function Devbox.available()
  if Devbox._available ~= nil then
    return Devbox._available
  end
  Devbox._available = vim.fn.executable(config.options.devbox_path) == 1
  return Devbox._available
end

--- Activate devbox env for the current buffer's project.
--- Sync by default (essential for LSP to inherit the PATH).
---@param dir? string
---@return boolean true if env was applied, false on failure
function Devbox.activate(dir)
  if not Devbox.available() then
    if not config.options.silent then
      vim.notify("[devbox] binary not found on PATH", vim.log.levels.WARN)
    end
    return false
  end

  dir = dir or vim.fn.expand("%:p:h")
  local root = Devbox.find_root(dir)
  if not root then
    return false
  end

  -- cache hit → instant
  if env_cache[root] then
    active_root = root
    Devbox._apply_env(env_cache[root])
    return true
  end

  if config.options.strategy == "async" then
    Devbox._async_load(root)
    return true
  end

  -- sync: run shellenv and wait
  if not config.options.silent then
    local name = vim.fn.fnamemodify(root, ":t")
    vim.notify("[devbox] resolving env for " .. name .. "...", vim.log.levels.INFO)
  end

  local ok, result = pcall(function()
    return vim.fn.system({ config.options.devbox_path, "shellenv" })
  end)

  if not ok or vim.v.shell_error ~= 0 then
    if not config.options.silent then
      vim.notify("[devbox] shellenv failed for " .. root, vim.log.levels.WARN)
    end
    return false
  end

  local parsed = Devbox._parse_shellenv(result)
  ---@type devbox.Env
  local env = {
    vars = parsed.vars,
    project_root = root,
    path = parsed.vars["PATH"] or "",
  }

  env_cache[root] = env
  active_root = root
  Devbox._apply_env(env)
  return true
end

--- Restore vim.env to the state before activation.
function Devbox.deactivate()
  if not active_root then
    return
  end
  for k, v in pairs(env_snapshot) do
    vim.env[k] = v
  end
  active_root = nil
  if not config.options.silent then
    vim.notify("[devbox] deactivated", vim.log.levels.INFO)
  end
end

---@return string?
function Devbox.get_active_root()
  return active_root
end

---@return boolean
function Devbox.is_active()
  return active_root ~= nil
end

--- Devbox PATH string (empty if inactive).
---@return string
function Devbox.get_path()
  local env = active_root and env_cache[active_root]
  return (env and env.path) or ""
end

--- Clear the env cache.
---@param project_root? string nil clears all entries
function Devbox.clear_cache(project_root)
  if project_root then
    env_cache[project_root] = nil
  else
    env_cache = {}
  end
end

--- Async alternative (optional, via opts.strategy = "async").
--- Non-blocking, but LSP may start without devbox PATH.
---@async
---@param root string
function Devbox._async_load(root)
  if not config.options.silent then
    vim.notify("[devbox] resolving env (async)...", vim.log.levels.INFO)
  end

  local chunks = {}
  local loaded = false

  vim.fn.jobstart({ config.options.devbox_path, "shellenv" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      chunks = data
    end,
    on_exit = vim.schedule_wrap(function(_, exit_code)
      if loaded or active_root then
        return
      end
      loaded = true

      if exit_code ~= 0 then
        if not config.options.silent then
          vim.notify("[devbox] shellenv failed (exit " .. exit_code .. ")", vim.log.levels.WARN)
        end
        return
      end

      local raw = table.concat(chunks, "\n")
      local parsed = Devbox._parse_shellenv(raw)
      ---@type devbox.Env
      local env = {
        vars = parsed.vars,
        project_root = root,
        path = parsed.vars["PATH"] or "",
      }

      env_cache[root] = env
      if not active_root then
        active_root = root
        Devbox._apply_env(env)
      end
    end),
  })
end

--- Prepend devbox PATH to an LSP client's cmd_env.
---@param client table|nil
function Devbox._inject_path(client)
  if not client or not client.config then
    return
  end
  local dp = Devbox.get_path()
  if dp == "" then
    return
  end
  client.config.cmd_env = client.config.cmd_env or {}
  local cur = client.config.cmd_env.PATH or vim.env.PATH or ""
  if not cur:find(dp, 1, true) then
    client.config.cmd_env.PATH = dp .. ":" .. cur
  end
end

--- Parse `export KEY=VALUE` lines from `devbox shellenv` output.
---@param raw string
---@return { vars: table<string,string> }
function Devbox._parse_shellenv(raw)
  local vars = {}
  for line in raw:gmatch("([^\n]+)") do
    local key, val = line:match("^export%s+([%a_][%w_]*)%s*=%s*(.*)$")
    if key and val then
      val = val:gsub('^"?(.-)"?%s*;?$', "%1")
      val = val:gsub('\\"', '"')
      val = val:gsub("\\\\", "\\")
      if not Devbox._is_excluded(key) then
        vars[key] = val
      end
    end
  end
  return { vars = vars }
end

--- Check whether an env var key matches the exclude pattern list.
---@param key string
---@return boolean
function Devbox._is_excluded(key)
  local excludes = config.options.exclude_env
  if not excludes then
    return false
  end
  for _, p in ipairs(excludes) do
    if key:find(p) then
      return true
    end
  end
  return false
end

--- Apply a parsed devbox env to vim.env.
--- Takes a snapshot on first call to allow deactivate().
---@param env devbox.Env
function Devbox._apply_env(env)
  if tbl_count(env_snapshot) == 0 then
    for k, v in pairs(vim.env) do
      env_snapshot[k] = v
    end
  end
  for k, v in pairs(env.vars) do
    if not Devbox._is_excluded(k) then
      vim.env[k] = v
    end
  end
  if not config.options.silent then
    local name = vim.fn.fnamemodify(env.project_root, ":t")
    vim.notify(
      string.format("[devbox] activated %s (%d vars)", name, tbl_count(env.vars)),
      vim.log.levels.INFO
    )
  end
end

return Devbox
