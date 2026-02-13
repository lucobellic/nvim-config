return {
  dir = vim.fn.stdpath('config') .. '/local/inlay-hints-custom',
  name = 'inlay-hints-custom',
  event = 'LspAttach',
  cond = false,
  ---@type InlayHintsCustomConfig
  opts = {
    virt_text_pos = 'right_align',
    separator = ' | ',
    format_hint = function(hint, bufnr, client_id)
      local client = vim.lsp.get_client_by_id(client_id)
      hint.label = hint.label:gsub('^: ', '')

      if client and client.name == 'clangd' and hint.kind == 2 then
        return { label = hint.label, virt_text_pos = 'inline' }
      end

      return require('inlay-hints-custom.render').default_format_hint(hint, bufnr, client_id)
    end,
  },
}
