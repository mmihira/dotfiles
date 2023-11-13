local present, starter = pcall(require, "mini.starter")
if not present then
  return
end

starter.setup()
