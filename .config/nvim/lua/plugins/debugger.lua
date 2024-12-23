local js_based_languages = {
  'typescript',
  'javascript',
  'typescriptreact',
  'javascriptreact',
  'vue',
}

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
    },
    {
      '<leader>dr',
      function()
        require('dap').continue()
      end,
    },
    {
      "<C-'>",
      function()
        require('dap').step_over()
      end,
    },
    {
      '<C-;>',
      function()
        require('dap').step_into()
      end,
    },
    {
      '<C-:>',
      function()
        require('dap').step_out()
      end,
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    dap.adapters.firefox = {
      type = 'executable',
      command = 'node',
      args = {
        require('mason-registry').get_package('firefox-debug-adapter'):get_install_path() .. '/dist/adapter.bundle.js',
      },
    }
    -- Configuration for JavaScript/TypeScript languages
    for _, language in ipairs(js_based_languages) do
      dap.configurations[language] = {
        {
          type = 'firefox',
          request = 'launch',
          name = 'Launch & Debug in Firefox',
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = 'Enter URL: ',
                default = 'http://localhost:8080',
              }, function(url)
                if url == nil or url == '' then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = vim.fn.getcwd(),
          firefoxExecutable = '/usr/bin/firefox', -- Adjust if needed
        },
      }
    end

    -- Set up dap-ui
    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open { reset = true }
    end
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
    require('nvim-dap-virtual-text').setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
    }
  end,
}
