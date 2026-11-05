---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
    opts.filesystem.filtered_items.visible = true -- Hidden files ko visible rakhega
    opts.filesystem.filtered_items.hide_dotfiles = false -- .gitignore, .env wagarah hamesha show honge
    opts.filesystem.filtered_items.hide_gitignored = false -- gitignored files bhi show honge
    return opts
  end,
}
