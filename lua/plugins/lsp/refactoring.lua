return {
	"ThePrimeagen/refactoring.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("refactoring").setup({})
	end,
}
