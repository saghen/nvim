local M = {}

-- easier keymapping
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap ~= false
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- vim.pack.add, but loads plugins from ~/code/nvim/<name> instead, when they exist
function M.pack_add_dev(specs)
  local remote = {}
  for _, spec in ipairs(specs) do
    spec = type(spec) == 'string' and { src = spec } or spec
    local name = spec.name or spec.src:match('([^/]+)$'):gsub('%.git$', '')
    local path = vim.fs.normalize('~/code/nvim/' .. name)
    if vim.uv.fs_stat(path) then
      vim.opt.rtp:prepend(path)
      if vim.uv.fs_stat(path .. '/after') then vim.opt.rtp:append(path .. '/after') end
    else
      table.insert(remote, spec)
    end
  end
  vim.pack.add(remote)
end

-- runs `build` after vim.pack installs or updates the plugin
-- must be called before the plugin's vim.pack.add for the build to run on install
function M.pack_build(name, build)
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      if ev.data.spec.name ~= name or ev.data.kind == 'delete' then return end
      if not ev.data.active then vim.cmd.packadd(name) end
      build()
    end,
  })
end

return M
