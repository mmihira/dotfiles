return {
  name = "pm2_lsp_logs",
  builder = function()
    local log_path = vim.lsp.get_log_path()
    local log_dir = vim.fn.fnamemodify(log_path, ":h")
    local pm2_name = "nvim_lsp_logs"
    local tail = vim.fn.exepath("tail")
    local perl = vim.fn.exepath("perl")

    if tail == "" then
      tail = "tail"
    end

    vim.fn.mkdir(log_dir, "p")
    vim.fn.writefile({}, log_path, "a")

    local logs_cmd = string.format("pm2 logs --raw %s", vim.fn.shellescape(pm2_name))
    if perl ~= "" then
      local parse_lsp_log = [=[
while (my $line = <STDIN>) {
  chomp $line;
  if ($line =~ /^\[([^\]]+)\]\[([^\]]+)\].*\t"((?:[^"\\]|\\.)*)"\s*$/) {
    my ($level, $date, $message) = ($1, $2, $3);
    $message =~ s/\\n/\n/g;
    $message =~ s/\\t/\t/g;
    $message =~ s/\\"/"/g;
    for my $part (split /\n/, $message) {
      next unless $part =~ /\S/;
      print "[$level][$date] $part\n";
    }
  } else {
    print "$line\n";
  }
}
]=]
      logs_cmd = string.format(
        "%s | %s -e %s",
        logs_cmd,
        vim.fn.shellescape(perl),
        vim.fn.shellescape(parse_lsp_log)
      )
    end

    return {
      name = "pm2_lsp_logs",
      cmd = string.format(
        "pm2 describe %s >/dev/null 2>&1 || pm2 start %s --name %s -- -f %s; %s",
        vim.fn.shellescape(pm2_name),
        vim.fn.shellescape(tail),
        vim.fn.shellescape(pm2_name),
        vim.fn.shellescape(log_path),
        logs_cmd
      ),
      cwd = vim.fn.getcwd(),
      components = {
        { "open_output", on_start = "always", direction = "vertical", focus = true },
        "scroll_output_to_bottom",
        { "unique",      soft = true },
        "default",
      },
    }
  end,
}
