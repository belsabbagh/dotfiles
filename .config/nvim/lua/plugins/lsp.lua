return {

  'neovim/nvim-lspconfig',
  dependencies = {

    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    { 'j-hui/fidget.nvim', opts = {} },

    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
    local mason_registry = require 'mason-registry'
    local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
    local servers = {
      rust_analyzer = {
        filetypes = { 'rust' },
        capabilities = capabilities,
      },
      vtsls = {
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
        settings = {
          vtsls = {
            -- autoUseWorkspaceTsdk = true,
            tsserver = {
              globalPlugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = vue_language_server_path,
                  languages = { 'vue' },
                  configNamespace = 'typescript',
                  enableForWorkspaceTypeScriptVersions = true,
                },
              },
            },
          },
        },
        capabilities = capabilities,
      },
      html = {
        filetypes = { 'html' },
        capabilities = capabilities,
        opts = {
          settings = {
            html = {
              format = {
                templating = true,
                wrapLineLength = 120,
                wrapAttributes = 'auto',
              },
              hover = {
                documentation = true,
                references = true,
              },
            },
          },
        },
      },
      biome = {
        capabilities = capabilities,
      },
      svelte = {
        capabilities = capabilities,
      },
      phpactor = {
        filetypes = { 'php' },
        capabilities = capabilities,
      },
      vuels = {
        filetypes = { 'vue' },
        capabilities = capabilities,
        init_options = {
          config = {
            css = {},
            emmet = {},
            html = {
              suggest = {},
            },
            javascript = {
              format = {},
            },
            stylusSupremacy = {},
            typescript = {
              format = {},
            },
            vetur = {
              completion = {
                autoImport = true,
                tagCasing = 'kebab',
                useScaffoldSnippets = true,
              },
              format = {
                defaultFormatter = {
                  js = 'biome',
                  ts = 'biome',
                },
                defaultFormatterOptions = {},
                scriptInitialIndent = false,
                styleInitialIndent = false,
              },
              useWorkspaceDependencies = false,
              validation = {
                script = true,
                style = true,
                template = true,
                templateProps = true,
                interpolation = true,
              },
              experimental = {
                templateInterpolationService = true,
              },
            },
          },
        },
      },
      pyright = {
        settings = {
          pyright = {
            disableOrganizeImports = true, -- Using Ruff
          },
          python = {
            analysis = {
              ignore = { '*' }, -- Using Ruff
              typeCheckingMode = 'off', -- Using mypy
            },
          },
        },
      },
      gopls = {
        capabilities = capabilities,
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}

          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
