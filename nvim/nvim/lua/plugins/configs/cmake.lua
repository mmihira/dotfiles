local present, cmake = pcall(require, "cmake-tools")
if not present then
  return
end

cmake.setup({
  cmake_executor = {
    name = "terminal",
    default_opts = {
      terminal = {
        name = "cmake",
        split_direction = "vertical",
        split_size = 80,
        focus = true,
      },
    },
  },
})
