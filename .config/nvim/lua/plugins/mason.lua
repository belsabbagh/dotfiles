return {
  'williamboman/mason.nvim',
  opts = {
    ensure_installed = {
      'typescript-language-server',
      'biome',
      'svelte-language-server',
      'vue-language-server',
      'gopls',
      'rust-analyzer',
      'stylua',
      'html-lsp',
      'ruff',
      'mypy',
      'pyright',
    },
  },
}
