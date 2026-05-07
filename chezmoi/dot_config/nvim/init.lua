-- Minimal Neovim config — bootstrapped by mac-workstation setup
-- Plugin manager: lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core options
vim.g.mapleader      = " "
vim.opt.number       = true
vim.opt.relativenumber = true
vim.opt.expandtab    = true
vim.opt.shiftwidth   = 2
vim.opt.tabstop      = 2
vim.opt.termguicolors = true
vim.opt.signcolumn   = "yes"
vim.opt.cursorline   = true
vim.opt.wrap         = false
vim.opt.ignorecase   = true
vim.opt.smartcase    = true
vim.opt.splitbelow   = true
vim.opt.splitright   = true

-- Plugins
require("lazy").setup({
  -- Colorscheme
  { "folke/tokyonight.nvim", priority = 1000, config = function()
    vim.cmd.colorscheme("tokyonight-night")
  end },

  -- File explorer
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("nvim-tree").setup() end,
  },

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>" },
    },
  },

  -- Status line
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("lualine").setup({ theme = "tokyonight" }) end,
  },

  -- Git signs in gutter
  { "lewis6991/gitsigns.nvim", config = true },

  -- Treesitter syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript",
                             "bash", "json", "yaml", "markdown" },
        highlight = { enable = true },
      })
    end,
  },
})

-- Basic keymaps
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
