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
          icon = '',
        },
      },
    },
  },
}
