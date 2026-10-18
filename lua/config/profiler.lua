if os.getenv('NVIM_PROFILE') == 'start' then
  local snacks = vim.fn.stdpath('data') .. '/site/pack/core/opt/snacks.nvim'
  vim.opt.rtp:append(snacks)
  require('snacks.profiler').startup({
    startup = {
      -- event = 'VimEnter', -- stop profiler on this event. Defaults to `VimEnter`
      event = 'UIEnter',
    },
  })
end
