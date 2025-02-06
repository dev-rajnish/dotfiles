return {
	"LudoPinelli/comment-box.nvim",
	config = function()
		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }
		local cb = require("comment-box")

		-- left aligned fixed size box with left aligned text
		keymap({ "n", "v" }, "<Leader>c", "", { desc = "comment box" })
		keymap({ "n", "v" }, "<Leader>cb", "<Cmd>CBllbox<CR>", opts)
		-- centered adapted box
		keymap({ "n", "v" }, "<Leader>cc", "<Cmd>CBacbox<CR>", opts)

		-- left aligned titled line with left aligned text
		keymap({ "n", "v" }, "<Leader>ct", "<Cmd>llline<CR>", opts)

		-- centered line
		keymap("n", "<Leader>cl", "<Cmd>CBcline<CR>", opts)
		keymap("i", "<M-l>", "<Cmd>CBcline<CR>", opts)

		-- remove a box or a titled line
		keymap({ "n", "v" }, "<Leader>cd", "<Cmd>CBd<CR>", opts)
	end,
}
-- ╭─────────────────────────────────────────────────────────╮
-- │ oino isnoio                                             │
-- │ niosino                                                 │
-- │ nioosnios                                               │
-- │ nsotesonuuonoes                                         │
-- │ onosnr                                                  │
-- │ onsini                                                  │
-- │                                                         │
-- ╰─────────────────────────────────────────────────────────╯
