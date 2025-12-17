return {
  get_content = function(args)
    local content =
      'Create a Neovim command-line command (:) that sends the current errors to the quickfix list and updates diagnostics using the Neovim API.\n'
    local example = [[
      :lua do local ns = vim.api.nvim_create_namespace('review');

        -- For each files:
        local bufnr = vim.fn.bufnr('/full/path/to/your/file.txt');
        if bufnr ~= -1 then
          local diagnostics = {{bufnr=bufnr, lnum=324, col=0, message='This is the ErrorMessage', severity=vim.diagnostic.severity.ERROR}};
          vim.diagnostic.set(ns, bufnr, diagnostics);
          vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics), 'a');
        end
      end
    ]]

    return content .. '\nExample:\n' .. example:gsub('\n', ' '):gsub(' +', ' ')
  end,
}
