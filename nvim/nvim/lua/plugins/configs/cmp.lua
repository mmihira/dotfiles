local present, cmp = pcall(require, "cmp")

if not present then
  return
end

local border = {
  { "╭", "CmpBorder" },
  { "─", "CmpBorder" },
  { "╮", "CmpBorder" },
  { "│", "CmpBorder" },
  { "╯", "CmpBorder" },
  { "─", "CmpBorder" },
  { "╰", "CmpBorder" },
  { "│", "CmpBorder" },
}

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources(
    { { name = "nvim_lsp" } },
    { { name = "luasnip" } },
    { { name = "buffer", keyword_length = 3 } },
    { { name = "nvim_lsp_signature_help" } },
    { { name = "path", keyword_length = 3 } }
  ),
  window = {
    documentation = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
    completion = {
      border = border,
      winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
    },
  },
  experimental = { native_menu = false, ghost_text = true },
})

cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })

cmp.setup.cmdline(":", {
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- For snippets
require("luasnip.loaders.from_vscode").lazy_load()
