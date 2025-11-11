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
      astro = { 'prettier' },
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
      svelte = { 'biome', 'prettier', stop_after_first = true },
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
      ---@type conform.FileFormatterConfig
      ruff = {
        meta = {
          url = 'https://docs.astral.sh/ruff/',
          description = 'An extremely fast Python linter, written in Rust. Formatter subcommand.',
        },
        command = 'ruff',
        args = {
          'format',
          '--force-exclude',
          '--stdin-filename',
          '$FILENAME',
          '-',
        },
        range_args = function(self, ctx)
          return {
            'format',
            '--force-exclude',
            '--range',
            string.format('%d:%d-%d:%d', ctx.range.start[1], ctx.range.start[2] + 1, ctx.range['end'][1], ctx.range['end'][2] + 1),
            '--stdin-filename',
            '$FILENAME',
            '-',
          }
        end,
        stdin = true,
      },
      intelephense = {
        command = 'intelephense',
        args = {},
      },
    },
  },
}
