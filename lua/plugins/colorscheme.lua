return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- ensure it loads early so colorscheme is applied properly
		config = function()
			require("gruvbox").setup({
				-- these are the defaults, you can customize
				terminal_colors = true, -- set terminal colors (e.g. for :terminal)
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = true,
					emphasis = true,
					comments = true,
					operators = false,
					folds = true,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				inverse = true, -- invert background for search, diffs, statuslines and errors
				contrast = "", -- "hard", "soft", or empty string
				palette_overrides = {},
				overrides = {},
				dim_inactive = false,
				transparent_mode = false,
			})
			-- After setup, set the colorscheme
			vim.o.background = "dark" -- or "light"
			vim.cmd("colorscheme gruvbox")
		end,
	},
}
