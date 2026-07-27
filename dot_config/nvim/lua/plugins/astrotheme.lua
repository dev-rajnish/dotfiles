return {
  "AstroNvim/astrotheme",
  opts = {
    style = {
      italic_comments = true,
    },
    highlights = {
      astrodark = {
        modify_hl_groups = function(hl, c)
          if hl.Comment then hl.Comment.italic = true end
          if hl.Keyword then hl.Keyword.italic = true end
          if hl.Function then hl.Function.italic = true end
          if hl.Type then hl.Type.italic = true end
          if hl.Statement then hl.Statement.italic = true end
          if hl.Conditional then hl.Conditional.italic = true end
          if hl.Repeat then hl.Repeat.italic = true end
          if hl["@keyword"] then hl["@keyword"].italic = true end
          if hl["@function"] then hl["@function"].italic = true end
          if hl["@type"] then hl["@type"].italic = true end
          if hl["@variable"] then hl["@variable"].italic = true end
          if hl["@parameter"] then hl["@parameter"].italic = true end
        end,
      },
    },
  },
}
