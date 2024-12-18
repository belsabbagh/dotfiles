return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
  },
  config = function()
    local lint = require 'lint'
    -- Define a custom biome linter
    local mason_registry = require 'mason-registry'
    local biome_path = mason_registry.get_package('biome'):get_install_path() .. '/node_modules/@biomejs/biome/bin/biome'
    lint.linters.biome = {
      name = 'biome',
      cmd = biome_path, -- Command to run the linter
      args = { 'lint' }, -- Arguments for the command
      stdin = false, -- Send content via stdin
      append_fname = true, -- Automatically add the current file name to the command arguments
      stream = 'both', -- Result stream
      ignore_exitcode = true, -- Treat exit code != 1 as an error
      parser = function(output)
        local diagnostics = {}

        -- The diagnostic details we need are spread in the first 3 lines of
        -- each error report.  These variables are declared out of the FOR
        -- loop because we need to carry their values to parse multiple lines.
        local fetch_message = false
        local lnum, col, code, message

        -- When a lnum:col:code line is detected fetch_message is set to true.
        -- While fetch_message is true we will search for the error message.
        -- When a error message is detected, we will create the diagnostic and
        -- set fetch_message to false to restart the process and get the next
        -- diagnostic.
        for _, line in ipairs(vim.fn.split(output, '\n')) do
          if fetch_message then
            _, _, message = string.find(line, '%s×(.+)')

            if message then
              message = (message):gsub('^%s+×%s*', '')

              table.insert(diagnostics, {
                source = 'biomejs',
                lnum = tonumber(lnum) - 1,
                col = tonumber(col),
                message = message,
                code = code,
              })

              fetch_message = false
            end
          else
            _, _, lnum, col, code = string.find(line, '[^:]+:(%d+):(%d+)%s([%a%/]+)')

            if lnum then
              fetch_message = true
            end
          end
        end

        return diagnostics
      end, -- Custom parser for output
    }
    -- Set up linters by filetype
    lint.linters_by_ft = {
      vue = { 'biome' }, -- Lint Vue files using the overridden biome command
      javascript = { 'biome' },
      json = { 'biome' },
      typescript = { 'biome' },
      javascriptreact = { 'biome' },
      typescriptreact = { 'biome' },
      python = { 'ruff', 'mypy' },
      -- Add more filetypes as needed
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
