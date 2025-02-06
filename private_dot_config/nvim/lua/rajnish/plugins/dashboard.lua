return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			theme = "hyper",
			week_header = {
				enable,
				concat,
				append,
			},
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
