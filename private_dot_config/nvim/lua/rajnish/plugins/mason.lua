return {
	"williamboman/mason.nvim",
	config = function()
		require("mason").setup({
			ui = {
				check_outdated_packages_on_open = true,

				-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
				border = "none",

				---@since 1.0.0
				-- Width of the window. Accepts:
				-- - Integer greater than 1 for fixed width.
				-- - Float in the range of 0-1 for a percentage of screen width.
				width = 0.8,

				---@since 1.0.0
				-- Height of the window. Accepts:
				-- - Integer greater than 1 for fixed height.
				-- - Float in the range of 0-1 for a percentage of screen height.
				height = 0.9,

				icons = {
					---@since 1.0.0
					-- The list icon to use for installed packages.
					package_installed = "◍",
					---@since 1.0.0
					-- The list icon to use for packages that are installing, or queued for installation.
					package_pending = "◍",
					---@since 1.0.0
					-- The list icon to use for packages that are not installed.
					package_uninstalled = "◍",
				},

				keymaps = {
					---@since 1.0.0
					-- Keymap to expand a package
					toggle_package_expand = "<CR>",
					---@since 1.0.0
					-- Keymap to install the package under the current cursor position
					install_package = "i",
					---@since 1.0.0
					-- Keymap to reinstall/update the package under the current cursor position
					update_package = "u",
					---@since 1.0.0
					-- Keymap to check for new version for the package under the current cursor position
					check_package_version = "c",
					---@since 1.0.0
					-- Keymap to update all installed packages
					update_all_packages = "U",
					---@since 1.0.0
					-- Keymap to check which installed packages are outdated
					check_outdated_packages = "C",
					---@since 1.0.0
					-- Keymap to uninstall a package
					uninstall_package = "X",
					---@since 1.0.0
					-- Keymap to cancel a package installation
					cancel_installation = "<C-c>",
					---@since 1.0.0
					-- Keymap to apply language filter
					apply_language_filter = "<C-f>",
					---@since 1.1.0
					-- Keymap to toggle viewing package installation log
					toggle_package_install_log = "<CR>",
					---@since 1.8.0
					-- Keymap to toggle the help view
					toggle_help = "g?",
				},
			},
		})
	end,
}
