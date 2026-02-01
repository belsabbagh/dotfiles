return {
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            section_separators = { left = '', right = '' },
            component_separators = { left = '|', right = '|' },
            theme = vim.g.colors_name,
            refresh = {
                statusline = 1000,
            },
        },
        sections = {
        lualine_c = {
        {
        'filename',
        path = 1,
        },
        },
        lualine_x = {
                  {
                      'lsp_status',
                                icon = '', -- f013
                                          symbols = {
                                                        -- Standard unicode symbols to cycle through for LSP progress:
                                                        --             spinner
                                                        --             =
                                                        --             {
                                                          --             '⠋',
                                                          --             '⠙',
                                                          --             '⠹',
                                                          --             '⠸',
                                                          --             '⠼',
                                                          --             '⠴',
                                                          --             '⠦',
                                                          --             '⠧',
                                                          --             '⠇',
                                                          --             '⠏'
                                                          --             },
                                                          --                         --
                                                          --                         Standard
                                                          --                         unicode
                                                          --                         symbol
                                                          --                         for
                                                          --                         when
                                                          --                         LSP
                                                          --                         is
                                                          --                         done:
                                                          --                                     done
                                                          --                                     =
                                                          --                                     '✓',
                                                          --                                                 --
                                                          --                                                 Delimiter
                                                          --                                                 inserted
                                                          --                                                 between
                                                          --                                                 LSP
                                                          --                                                 names:
                                                          --                                                             separator
                                                          --                                                             =
                                                          --                                                             '
                                                          --                                                             ',
                                                          --                                                                       },
                                                          --                                                                                 --
                                                          --                                                                                 List
                                                          --                                                                                 of
                                                          --                                                                                 LSP
                                                          --                                                                                 names
                                                          --                                                                                 to
                                                          --                                                                                 ignore
                                                          --                                                                                 (e.g.,
                                                          --                                                                                 `null-ls`):
                                                          --                                                                                           ignore_lsp
                                                          --                                                                                           =
                                                          --                                                                                           {},
                                                          --                                                                                                     --
                                                          --                                                                                                     Display
                                                          --                                                                                                     the
                                                          --                                                                                                     LSP
                                                          --                                                                                                     name
                                                          --                                                                                                               show_name
                                                          --                                                                                                               =
                                                          --                                                                                                               true,
                                                          --                                                                                                                       },
                                                          --                                                                                                                               'encoding',
                                                          --                                                                                                                                       'fileformat',
                                                          --                                                                                                                                               'filetype',
                                                          --                                                                                                                                                     },
                                                          --                                                                                                                                                         },
                                                          --                                                                                                                                                           },
                                                          --                                                                                                                                                           }
                                          }
          }
}
}
}
}

