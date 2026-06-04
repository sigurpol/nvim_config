local ok_neotest, neotest = pcall(require, "neotest")
if not ok_neotest then
  return
end

local ok_adapter, adapter = pcall(require, "rustaceanvim.neotest")
if not ok_adapter then
  return
end

neotest.setup({
  adapters = {
    adapter,
  },
})

vim.keymap.set("n", "<leader>tt", function()
  neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tT", function()
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>to", function()
  neotest.output.open({ enter = true })
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>ts", function()
  neotest.summary.toggle()
end, { desc = "Toggle test summary" })
