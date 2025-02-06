return {
	"Mr-LLLLL/interestingwords.nvim",
	config = function()
		require("interestingwords").setup({
			colors = { "#aeee00", "#ff0000", "#0000ff", "#b88823", "#ffa724", "#ff2c4b" },
			search_count = true,
			navigation = true,
			scroll_center = true,
			search_key = "<leader>nm",
			cancel_search_key = "<leader>nM",
			color_key = "<leader>nk",
			cancel_color_key = "<leader>nK",
			select_mode = "random", -- random or loop
		})
	end,
}
