return {
  'nvim-mini/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup {
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
      },
    }
    require('mini.pairs').setup()
    require('mini.icons').setup()
-- require('mini.statusline').setup({
--   content = {
--     active = function()
--         local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
--         local git           = MiniStatusline.section_git({ trunc_width = 40 })
--         local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
--         local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
--         local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
--         local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
--         local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
--         local location      = MiniStatusline.section_location({ trunc_width = 75 })
--         local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })
--
--       return MiniStatusline.combine_groups({
--         { hl = mode_hl,                  strings = { mode } },
--         { hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics, diff } },
--         '%<', -- Mark truncation point
--         { hl = 'MiniStatuslineFilename', strings = { filename } },
--         '%=', -- Fill rest of screen
--         { hl = 'MiniStatuslineFileinfo', strings = { lsp, fileinfo } },
--         { hl = mode_hl,                  strings = { location } },
--       })
--     end,
--   },
-- })
  end,
}
