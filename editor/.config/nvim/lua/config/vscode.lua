-- ==============================================================================
-- VS Code Neovim Configuration
-- ==============================================================================
--
-- This file is loaded only when running inside VS Code via vscode-neovim
-- (`vim.g.vscode == true`).
--
-- Design notes:
-- - VS Code owns UI (statusline, sign column, color columns, etc.), so many UI
--   options from `init.lua` won't visually apply.
-- - VS Code generally provides LSP/completion; Neovim LSP plugins are usually
--   redundant here and can conflict with the VS Code experience.

local M = {}

function M.setup()
	-- Keep VS Code path minimal but still allow a few motion plugins that work
	-- without touching Neovim's UI (statusline/floating windows/etc.).

	-- Lightweight lazy.nvim bootstrap (mirrors standalone.lua but only pulls the
	-- plugins we want available inside VS Code).
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)

	require("lazy").setup({
		-- Motion: Leap (works fine in VS Code because it only moves the cursor).
		{
			"ggandor/leap.nvim",
			config = function()
				vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
				vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
			end,
		},
		-- Enhanced matching for %, [] motions; avoid popups that rely on UI.
		{
			"andymass/vim-matchup",
			config = function()
				vim.g.matchup_matchparen_offscreen = { method = "status" }
			end,
		},
	}, {
		checker = { enabled = false },
		change_detection = { notify = false },
	})

	-- Bridge常用 LSP/导航按键到 VS Code 命令，保持与终端 Neovim 手感一致。
	local ok, vscode = pcall(require, 'vscode')
	if ok then
		local map = function(mode, lhs, cmd, opts)
			vim.keymap.set(mode, lhs, function() vscode.action(cmd) end, vim.tbl_extend('force', { silent = true }, opts or {}))
		end

		-- 定义/声明/类型/实现/引用
		map('n', 'gd', 'editor.action.revealDefinition')
		map('n', 'gD', 'editor.action.revealDeclaration')
		map('n', 'gy', 'editor.action.goToTypeDefinition')
		map('n', 'gi', 'editor.action.goToImplementation')
		map('n', 'gr', 'editor.action.referenceSearch.trigger')

		-- 悬停
		map('n', 'K', 'editor.action.showHover')

		-- 重命名 / 代码动作 / 格式化
		map('n', '<leader>r', 'editor.action.rename')
		map({ 'n', 'v' }, '<leader>a', 'editor.action.quickFix')
		map('n', '<leader>f', 'editor.action.formatDocument')
		map('n', '<leader>w', 'workbench.action.files.save')

		-- 诊断导航（与 keybindings.json 保持一致，多一份映射以便不依赖外部和弦）
		map('n', '[d', 'editor.action.marker.prev')
		map('n', ']d', 'editor.action.marker.next')
		map('n', '<leader>e', 'editor.action.showHover')
		map('n', '<leader>q', 'workbench.actions.view.problems')
	end
end

return M
