-- set leader key to space
vim.g.mapleader = " "

local k = vim.keymap -- for conciseness

--                              ╭─────────────────╮
--                              │ General Keymaps │
--                              ╰─────────────────╯
k.set("n", "<leader>w", "", { desc = "write / save" })
k.set("n", "<leader>ww", "<cmd>w<CR>", { desc = "write / save" })
k.set("n", "<leader>wQ", "<cmd>wqa<CR>", { desc = "save quiet all" })
k.set("n", "<leader>wq", "<cmd>wq<CR>", { desc = "save quiet" })
k.set("n", "<leader>wa", "<cmd>wa<CR>", { desc = "save all" })
k.set("n", "<leader>q", "", { desc = "quiet" })
k.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "quiet" })
k.set("n", "<leader>qa", "<cmd>qa!<CR>", { desc = "quiet all" })
-- ╭─────────────────────────────────────────────────────────╮
-- │ Applications                                            │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>a", "", { desc = "Applications" })
k.set("n", "<leader>am", "<cmd>Mason<CR>", { desc = "Mason" })
k.set("n", "<leader>al", "<cmd>Lazy<CR>", { desc = "Lazy" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ use jk to exit insert mode                              │
-- ╰─────────────────────────────────────────────────────────╯
k.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ clear search highlights                                 │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>n", "", { desc = "highlights" })
k.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ delete single character without copying into register   │
-- │ keymap.set("n", "x", '"_x')                             │
-- ╰─────────────────────────────────────────────────────────╯

-- ╭─────────────────────────────────────────────────────────╮
-- │ increment/decrement numbers                             │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
k.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- ╭─────────────────────────────────────────────────────────╮
-- │ window management                                       │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>s", "", { desc = "Window management" })
k.set("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })
k.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
k.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
k.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
k.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- ╭─────────────────────────────────────────────────────────╮
-- │ Tab management                                          │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>t", "", { desc = "Tab management" }) -- open new tab
k.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
k.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
k.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
k.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
k.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- ╭─────────────────────────────────────────────────────────╮
-- │ file manager                                            │
-- ╰─────────────────────────────────────────────────────────╯
k.set("n", "<leader>e", "", { desc = "File manager" })

k.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
k.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
k.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
k.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
