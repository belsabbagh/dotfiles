return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      '<leader>f',
      function()
        require('conform').format { async = true }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    notify_on_error = true,
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 1000,
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'gofmt' },
      python = { 'ruff', 'black', stop_after_first = true },
      javascript = { 'biome', 'prettier', stop_after_first = true },
      typescript = { 'biome', 'prettier', stop_after_first = true },
      html = { 'prettier', stop_after_first = true },
      css = { 'biome', 'prettier', stop_after_first = true },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      json = { 'biome', 'prettier', stop_after_first = true },
      astro = { 'prettier', 'biome', stop_after_first = true },
      vue = { 'biome', 'prettier' },
      svelte = { 'prettier', 'biome', stop_after_first = true },
      yaml = { 'prettier' },
      php = { 'pint', stop_after_first = true },
      typst = { 'typstyle', stop_after_first = true },
    },
  },
}
