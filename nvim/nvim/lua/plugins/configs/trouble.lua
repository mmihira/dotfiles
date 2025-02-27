local present, trouble = pcall(require, "trouble")
if not present then
  return
end

trouble.setup({
  focus = true,
  follow = false,
  modes = {
    lsp_doc_float = {
      mode = "lsp_document_symbols",
      keys = {
        ["<cr>"] = "jump_close",
      },
      win = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Document Symbols",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.35, height = 1 },
        zindex = 200,
      },
      filter = {
        kind = { "Method", "Function" },
      },
    },
    lsp_struct_float = {
      mode = "lsp_document_symbols",
      keys = {
        ["<cr>"] = "jump_close",
      },
      win = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Document Symbols",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.35, height = 1 },
        zindex = 200,
      },
      filter = {
        kind = { "Object" },
      },
    },
    qf_stack = {
      mode = "qflist",
      sort = {},
    },
  },
})
