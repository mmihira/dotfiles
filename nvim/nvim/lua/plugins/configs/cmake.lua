local present, cmake = pcall(require, "cmake-tools")
if not present then
  return
end

cmake.setup({
  -- cmake_executor = {
  --   name = "toggleterm",
  --   default_opts = {
  --     toggleterm = {
  --       direction = "float",
  --       close_on_exit = false,
  --       auto_scroll = true,
  --       singleton = false,
  --     },

  --   },
  -- },
})
