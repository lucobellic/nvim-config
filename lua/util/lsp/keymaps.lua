return function()
	local format = function()
		require("lazyvim.plugins.lsp.format").format({ force = true })
	end
	local keys = require("lazyvim.plugins.lsp.keymaps").get()

	keys[#keys + 1] = { "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>" }
	keys[#keys + 1] = { "gd", "<cmd>TroubleToggle lsp_definitions<CR>" }
	keys[#keys + 1] = { "K", "<cmd>lua vim.lsp.buf.hover()<CR>" }
	keys[#keys + 1] = { "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>" }
	keys[#keys + 1] = { "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>" }

	keys[#keys + 1] = { "gr", "<cmd>TroubleToggle lsp_references<CR>" }

	keys[#keys + 1] = { "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>" }
	keys[#keys + 1] = { "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>" }
	keys[#keys + 1] = { "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>" }

	keys[#keys + 1] = { "<leader>rf", '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>' }

	keys[#keys + 1] = { "<leader>cf", '<cmd>lua require("plugins.lsp.util.fixcurrent")()<CR>' }

	keys[#keys + 1] = {
		"<leader>ca",
		"<cmd>Lspsaga code_action<CR>",
		desc = "Code Action",
		mode = { "n", "v" },
		has = "codeAction",
	}

	-- Format
	keys[#keys + 1] = { "<leader>=", format, desc = "Format Document", has = "documentFormatting" }
	keys[#keys + 1] = { "<leader>=", format, desc = "Format Range", mode = "v", has = "documentRangeFormatting" }

	-- Lspsaga
	keys[#keys + 1] = { "<F2>", "<cmd>Lspsaga rename<CR>" }
	keys[#keys + 1] = { "gK", "<cmd>Lspsaga hover_doc<CR>" }

	-- Jump to previous or next diagnostic
	keys[#keys + 1] = { "<C", "<cmd>Lspsaga diagnostic_jump_prev<CR>" }
	keys[#keys + 1] = { ">C", "<cmd>Lspsaga diagnostic_jump_next<CR>" }

	-- Jump to warning or above
	keys[#keys + 1] = {
		"<W",
		function()
			require("lspsaga.diagnostic"):goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
		end,
	}

	keys[#keys + 1] = {
		">W",
		function()
			require("lspsaga.diagnostic"):goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
		end,
	}

	-- Jump to error
	keys[#keys + 1] = {
		"<E",
		function()
			require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
		end,
	}

	keys[#keys + 1] = {
		">E",
		function()
			require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
		end,
	}
end
