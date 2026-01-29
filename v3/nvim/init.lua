vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "

require("catppuccin").setup({
	flavour = "frappe",
})
vim.cmd.colorscheme("catppuccin")

-- require("telescope").setup({
--   extensions = {
--     ["ui-select"] = {
--       require("telescope.themes").get_dropdown {
--         -- even more opts
--       }
--
--       -- pseudo code / specification for writing custom displays, like the one
--       -- for "codeactions"
--       -- specific_opts = {
--       --   [kind] = {
--       --     make_indexed = function(items) -> indexed_items, width,
--       --     make_displayer = function(widths) -> displayer
--       --     make_display = function(displayer) -> function(e)
--       --     make_ordinal = function(e) -> string
--       --   },
--       --   -- for example to disable the custom builtin "codeactions" display
--       --      do the following
--       --   codeactions = false,
--       -- }
--     }
--   }
-- })
-- require("telescope").load_extension("ui-select")
local telescope = require("telescope").setup({})
local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", telescope_builtin.git_files, {})
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, {})
vim.keymap.set("n", "<leader>ft", telescope_builtin.treesitter, {})
vim.keymap.set("n", "<leader>fs", telescope_builtin.live_grep, {})
-- vim.keymap.set("n", "<leader>fs", function()
-- 	telescope_builtin.grep_string({ search = vim.fn.input("Grep > ") })
-- end)

require("nvim-treesitter").setup({
	ensure_installed = {},
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
	incremental_selection = {
		enable = true,
	},
})

-- vim.lsp.enable("lua_ls")

-- vim.lsp.config("rust_analyzer", {
-- 	on_attach = function(client, bufnr)
-- 		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
-- 	end,
-- 	settings = {
-- 		["rust-analyzer"] = {},
-- 	},
-- })

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local lspconfig = require("lspconfig")
vim.lsp.config["roslyn_ls"] = {
	capabilities = capabilities,
};
vim.lsp.enable("roslyn_ls");
-- vim.lsp.config["omnisharp"] = {
-- 	capabilities = capabilities,
-- };
-- vim.lsp.enable("omnisharp");
vim.lsp.config["lua_ls"] = {
	capabilities = capabilities,
};
vim.lsp.enable("lua_ls");
vim.lsp.config["rust_analyzer"] = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end,
	settings = {
		["rust-analyzer"] = {
			procMacro = {
				enable = true,
			},
			diagnostics = {
				experimental = {
					enable = false,
				},
			},
			cargo = {
				-- features = { "ssr" },
				features = "all",
				-- allFeatures = true,
			},
		},
	},
};
vim.lsp.enable("rust_analyzer");
-- lspconfig.lua_ls.setup({
-- 	capabilities = capabilities,
-- })
-- lspconfig.rust_analyzer.setup({
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
-- 	end,
-- 	settings = {
-- 		["rust-analyzer"] = {
-- 			procMacro = {
-- 				enable = true,
-- 			},
-- 			diagnostics = {
-- 				experimental = {
-- 					enable = false,
-- 				},
-- 			},
-- 			cargo = {
-- 				-- features = { "ssr" },
-- 				features = "all",
-- 				-- allFeatures = true,
-- 			},
-- 		},
-- 	},
-- })

local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.nixfmt,
	},
})

-- vim.lsp.enable("rust_analyzer")

vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", function()
	vim.lsp.buf.definition({
		on_list = function(options)
			local items = options.items
			local cwd = vim.fn.getcwd()
			local cwd_parts = vim.split(cwd, "/")
			local cwd_parts_last = cwd_parts[#cwd_parts]
			local contains_local = nil

			for index, item in pairs(items) do
				local filename = item.filename
				vim.print(filename)
				local is_local = string.find(filename, cwd_parts_last)
				if is_local then
					contains_local = index
					break
				end
			end

			if contains_local then
				vim.fn.setqflist(
					{},
					" ",
					{ title = options.title, items = { items[contains_local] }, context = options.context }
				)
				vim.cmd.cfirst()
				return
			end

			vim.fn.setqflist({}, " ", { title = options.title, items = items, context = options.context })

			if #items == 1 then
				vim.cmd.cfirst()
				return
			end
			-- print(items)
			-- vim.fn.setqflist({}, " ", { title = options.title, items = items, context = options.context })
			-- vim.cmd.cfirst()

			-- vim.cmd.lpf()
			-- vim.fn.getqflist()
			-- vim.cmd.lopen()
			vim.cmd("botright copen")
		end,
	})
end) -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
-- vim.keymap.set("n", "gd", function()
--     vim.lsp.buf.definition({ on_list = function(options)
--         local items = options.items
--         if #items > 2 then
--             items[0] = items[1]
--         end
--         vim.fn.setqflist({}, ' ', { title = options.title, items = items, context = options.context })
--         vim.cmd.cfirst()
--
--     end
--     })
-- end)
vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, {})

local cmp = require("cmp")
require("luasnip.loaders.from_vscode").load()

local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
			-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

			-- For `mini.snippets` users:
			-- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
			-- insert({ body = args.body }) -- Insert at cursor
			-- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
			-- require("cmp.config").set_onetime({ sources = {} })
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-l>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, -- For luasnip users.
		-- { name = 'vsnip' }, -- For vsnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer" },
	}),
})

-- require("lsp-progress").setup()
--
-- local function LspStatus()
-- 	return require("lsp-progress").progress({
-- 		format = function(messages)
-- 			return #messages > 0 and table.concat(messages, " ") or ""
-- 		end,
-- 	})
-- end

require("lualine").setup({
	options = {
		component_separators = { left = "|", right = "|" },
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					return str:sub(1, 1)
				end,
			},
		},
		lualine_b = {
			"diagnostics",
			{ "branch", icons_enabled = false },
		},
		lualine_c = {
			"filename",
			{
				"lsp_status",
				icon = "", -- f013
				symbols = {
					-- Standard unicode symbols to cycle through for LSP progress:
					spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
					-- Standard unicode symbol for when LSP is done:
					done = "✓",
					-- Delimiter inserted between LSP names:
					separator = " ",
				},
				-- List of LSP names to ignore (e.g., `null-ls`):
				ignore_lsp = {},
			},
			-- function()
			-- 	return require("lsp-progress").progress()
			-- end,
			-- function()
			-- 	return require("lsp-progress").progress({
			-- 		format = function(messages)
			-- 			print(messages)
			-- 			return #messages
			-- 			-- return #messages > 0 and table.concat(messages, " ") or ""
			-- 		end,
			-- 	})
			-- end,
		},
	},
	tabline = {
		lualine_a = {
			"buffers",
		},
	},
})

vim.diagnostic.config({
	-- update_in_insert = true,
	virtual_text = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})
vim.keymap.set("n", "<leader>cd", function()
	vim.diagnostic.open_float()
end)

local trouble = require("trouble")
trouble.setup({})
-- trouble.
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>")
-- vim.keymap.set("n", "<leader>xj", function()
-- 	vim.cmd([[ Trouble diagnostics next ]])
-- end)
-- vim.keymap.set("n", "<leader>xk", function()
-- 	vim.cmd([[ Trouble diagnostics prev ]])
-- end)

vim.keymap.set("n", "<leader>xx", function()
	vim.cmd([[ Trouble diagnostics toggle ]])
end)
vim.keymap.set("n", "<leader>xj", function()
	vim.cmd([[ Trouble diagnostics next ]])
end)
vim.keymap.set("n", "<leader>xk", function()
	vim.cmd([[ Trouble diagnostics prev ]])
end)

-- vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
-- vim.api.nvim_create_autocmd("User", {
-- 	group = "lualine_augroup",
-- 	pattern = "LspProgressStatusUpdated",
-- 	callback = require("lualine").refresh,
-- })

require("smear_cursor").setup({})
require("neoscroll").setup({
	duration_multiplier = 0.2,
	performance_mode = true,
	-- duration_multiplier = 0.2,
	-- performance_mode = true,
})

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>h", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<leader>5", function()
	harpoon:list():select(5)
end)
vim.keymap.set("n", "<leader>6", function()
	harpoon:list():select(6)
end)
vim.keymap.set("n", "<leader>7", function()
	harpoon:list():select(7)
end)
vim.keymap.set("n", "<leader>8", function()
	harpoon:list():select(8)
end)
vim.keymap.set("n", "<leader>9", function()
	harpoon:list():select(9)
end)
vim.keymap.set("n", "<leader>0", function()
	harpoon:list():select(10)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

require("marks").setup({})

require("treesitter-context").setup({
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	-- multiwindow = false, -- Enable multiwindow support.
	max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
	-- min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	-- line_numbers = true,
	multiline_threshold = 1, -- Maximum number of lines to show for a single context
	-- trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	-- mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
	-- -- Separator between context and content. Should be a single character string, like '-'.
	-- -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	-- separator = nil,
	-- zindex = 20, -- The Z-index of the context window
	-- on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})

require('neo-tree').setup({
  -- options go here
})

vim.keymap.set("n", "<leader>e", function()
    require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
end)

require("outline").setup({})

vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>")


