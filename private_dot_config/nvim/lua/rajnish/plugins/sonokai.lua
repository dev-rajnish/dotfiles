return {
	"sainnhe/sonokai",
	lazy = false,
	priority = 1000,
	config = function()
		-- Optionally configure and load the colorscheme
		-- directly inside the plugin declaration.
		vim.g.sonokai_style = "maia" -- andromeda, atlantis, maia
		vim.g.sonokai_transparent_background = 2
		vim.g.sonokai_disable_terminal_colors = 0
		vim.g.sonokai_enable_italic = true
		vim.cmd.colorscheme("sonokai")
	end,
}
