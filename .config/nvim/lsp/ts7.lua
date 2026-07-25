local function resolve_bin(root_dir)
  local candidates = { 'tsc' }
  if root_dir then
    table.insert(candidates, 1, root_dir .. '/node_modules/.bin/tsc')
  end
  for _, bin in ipairs(candidates) do
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
end

local function check_version(bin)
  local ver = vim.fn.system({ bin, '--version' })
  local major = tonumber(ver:match('Version (%d+)'))
  return major and major >= 7, major
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local bin = resolve_bin(config.root_dir)
    return vim.lsp.rpc.start({ bin, '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    root_markers = vim.fn.has 'nvim-0.11.3' == 1 and { root_markers, { '.git' } } or vim.list_extend(root_markers, { '.git' })

    if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
      return
    end

    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    local bin = resolve_bin(project_root)
    if not bin then return end

    local ok, major = check_version(bin)
    if not ok then
      vim.notify(('ts7: need TypeScript >=7, got %d'):format(major or 0), vim.log.levels.WARN)
      return
    end

    on_dir(project_root)
  end,
}
