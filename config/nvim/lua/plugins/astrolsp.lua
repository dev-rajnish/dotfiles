-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable codelens refresh on start
      inlay_hints = true, -- enable inlay hints on start (shows types inline like VSCode!)
      semantic_tokens = true, -- enable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      format_on_save = {
        enabled = true,
      },
      timeout_ms = 3000,
    },
    -- customize language server configuration passed to `vim.lsp.config`
    config = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = true,
            check = {
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always", useParameterNames = true },
              parameterHints = { enable = true },
              reborrowHints = { enable = "always" },
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        K = {
          function()
            if vim.bo.filetype == "rust" and pcall(require, "rustaceanvim") then
              vim.cmd.RustLsp { "hover", "actions" }
            else
              vim.lsp.buf.hover()
            end
          end,
          desc = "Hover documentation / actions",
        },
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
  },
}
