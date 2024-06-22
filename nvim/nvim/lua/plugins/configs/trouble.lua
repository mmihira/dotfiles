local present, trouble = pcall(require, "trouble")
if not present then
  return
end

trouble.setup({
  focus = true,
  modes = {
    lsp_doc_float = {
      mode = "lsp_document_symbols",
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
        kind = "Method",
      },
    },
    ref_float = {
      mode = "lsp_references",
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
    },
    imp_float = {
      mode = "lsp_impementations",
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
    },
  },
})
