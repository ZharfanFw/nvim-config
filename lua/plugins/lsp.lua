return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			{
				"mason-org/mason-lspconfig.nvim",
				opts = {
					automatic_enable = {
						exclude = { "jdtls" }, -- handled manually
					},
				},
			},
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},

		---------------------------------------------------------------------------
		-- 🔧 LSP UI + keymaps
		---------------------------------------------------------------------------
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "Rename symbol")
					map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "Find references")
					map("gri", require("telescope.builtin").lsp_implementations, "Goto implementation")
					map("grd", require("telescope.builtin").lsp_definitions, "Goto definition")
					map("grD", vim.lsp.buf.declaration, "Goto declaration")
					map("grt", require("telescope.builtin").lsp_type_definitions, "Goto type definition")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Document symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle inlay hints")
					end
				end,
			})

			---------------------------------------------------------------------------
			-- ⚙️ Diagnostics
			---------------------------------------------------------------------------
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(d)
						return d.message
					end,
				},
			})

			---------------------------------------------------------------------------
			-- 🧠 Capabilities (Blink completion)
			---------------------------------------------------------------------------
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			---------------------------------------------------------------------------
			-- 🚀 Language servers
			---------------------------------------------------------------------------
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = {
									"${3rd}/luv/library",
									unpack(vim.api.nvim_get_runtime_file("", true)),
								},
							},
							diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
						},
					},
				},
				pylsp = {
					settings = {
						pylsp = {
							plugins = {
								pyflakes = { enabled = false },
								pycodestyle = { enabled = false },
								autopep8 = { enabled = false },
								yapf = { enabled = false },
								mccabe = { enabled = false },
								pylsp_mypy = { enabled = false },
								pylsp_black = { enabled = false },
								pylsp_isort = { enabled = false },
							},
						},
					},
				},
				ruff = {},
				jsonls = {},
				sqlls = {},
				cssls = {},
				tailwindcss = {},
				html = { filetypes = { "html", "twig", "hbs" } },
			}

			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "typescript", "javascript", "vue", "typescriptreact", "javascriptreact" },
				root_markers = { "package.json", "tsconfg.json", ".git" },
			})

			-- optional: tailwindcss (safe to attach to vue)
			vim.lsp.config("tailwindcss", {
				cmd = { "tailwindcss-language-server", "--stdio" },
				filetypes = { "vue", "html", "css", "javascript", "typescript" },
				root_markers = { "tailwind.config.js", "postcss.config.js", "package.json", ".git" },
			})

			---------------------------------------------------------------------------
			-- 🧰 Mason setup (auto-installs servers + tools)
			---------------------------------------------------------------------------
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-------------------------------------------------------------------------------
	-- ☕ Java support
	-------------------------------------------------------------------------------
	{ "mfussenegger/nvim-jdtls" },
}
