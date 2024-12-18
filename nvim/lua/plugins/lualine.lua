return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
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
    },
  },
}
