local present, cmp = pcall(require, "cmp")
local luasnip = require("luasnip")

if not present then
  return
end

vim.keymap.set({ "i", "s" }, "<C-l>", function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end)

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

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
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
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "copilot",  group_index = 2, priority = 3 },
    { name = "nvim_lsp", group_index = 2, priority = 2, max_item_count = 5 },
    { name = "luasnip",  group_index = 1, priority = 1 },
    { name = "buffer",   group_index = 2, priority = 1, max_item_count = 5 },
    -- { name = "path" },
  },
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

-- prompt for the command line search
-- cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })

cmp.setup.cmdline(":", {
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- For snippets
require("luasnip.loaders.from_vscode").lazy_load()
