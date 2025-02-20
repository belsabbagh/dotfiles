return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[C]ode [F]ormat',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 1000,
    },
    formatters_by_ft = {
      lua = { 'stylua' },

      go = { 'gofmt' },
      python = { 'ruff' },
      javascript = { 'biome', 'prettier', stop_after_first = true },
      typescript = { 'biome', 'prettier', stop_after_first = true },
      html = { 'prettier' },
      css = { 'prettier' },
      yaml = { 'prettier' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      json = { 'biome', 'prettier', stop_after_first = true },
      vue = { 'biome', 'prettier' },
      php = { 'pint', 'intelephense', stop_after_first = true },
    },
    formatters = {
      biome = {
        meta = {
          url = 'https://github.com/biomejs/biome',
          description = 'A toolchain for web projects, aimed to provide functionalities to maintain them.',
        },
        command = 'biome',
        stdin = true,
        args = { 'format', '--stdin-file-path', '$FILENAME' },
      },
      intelephense = {
        command = 'intelephense',
        args = {},
      },
    },
  },
}
