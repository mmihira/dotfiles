local present, cmake = pcall(require, "cmake-tools")
if not present then
  return
end

cmake.setup({
  cmake_generate_options = { "-G Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
  cmake_build_directory = "out/${variant:buildType}",
  cmake_soft_link_compile_commands = true,
  cmake_executor = {
    name = "toggleterm",
    default_opts = {
      toggleterm = {
        direction = "float",
        close_on_exit = false,
        auto_scroll = true,
        singleton = false,
      },
    },
  },
  cmake_use_preset = false,
})
