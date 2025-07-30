local M = {}

local cl_options		= require("cheat-line.cl_options").config
local cl_extmarks		= require("cheat-line.cl_extmarks")
local cl_char_based_gen	= require("cheat-line.cl_char_based_generation")
local cl_word_based_gen	= require("cheat-line.cl_word_based_generation")
local cl_highlight		= require("cheat-line.cl_highlight")

local cl_options_wb = cl_options.word_based
local cl_options_cb = cl_options.char_based

local cl_str_manipulations = require("cheat-line.cl_str_manipulations")

-- update cheat line using word-based generation
function Update_word_based_cheat_line ()
	if (cl_options.cheat_line_enabled == false) then
		M.Enable_cheat_line()
		return
	end

	local tmp = vim.api.nvim_buf_line_count(0)
	if (tmp < 3) then
		return
	end

	local current_line_pos = vim.api.nvim_win_get_cursor(0)[1]-1	--getting line number
	local cursor_position = vim.api.nvim_win_get_cursor(0)[2]		--getting cursor position on the line

	-- generate text for cheat lines
	local lines_txt = cl_word_based_gen.Generate_cheat_line_text(
																	current_line_pos,
																	cursor_position
																)

	local line_1_pos = current_line_pos+cl_options_wb.line_1_relative_pos
	local line_2_pos = current_line_pos+cl_options_wb.line_2_relative_pos

	local lines_total = vim.fn['line']('w$')-vim.fn["line"]('w0')+1

	if (line_1_pos+1 < vim.fn["line"]('w0')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn["line"]('w$')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_low
	end
	if (line_2_pos+1 < vim.fn["line"]('w0')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_high
	end
	if (line_2_pos+1 > vim.fn["line"]('w$')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_low
	end

	cl_extmarks.Edit_extmarks(
								lines_txt[1],
								lines_txt[2],
								line_1_pos,
								line_2_pos
							 )
end

-- update cheat line using char-based generation
function Update_char_based_cheat_line ()
	local line_1 = cl_str_manipulations.Stretch_to_the_buffer("line_1")
	local line_2 = cl_str_manipulations.Stretch_to_the_buffer("line_2")

	local current_line_pos = vim.api.nvim_win_get_cursor(0)[1]-1	--getting line number
	local cursor_position = vim.api.nvim_win_get_cursor(0)[2]		--getting cursor position on the line

	local lines_txt = cl_char_based_gen.Generate_cheat_line_text(
																	current_line_pos,
																	cursor_position
																)

	local line_1_pos = current_line_pos+cl_options_wb.line_1_relative_pos
	local line_2_pos = current_line_pos+cl_options_wb.line_2_relative_pos

	local lines_total = vim.fn['line']('w$')-vim.fn["line"]('w0')+1

	if (line_1_pos+1 < vim.fn["line"]('w0')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn["line"]('w$')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_low
	end
	if (line_2_pos+1 < vim.fn["line"]('w0')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_high
	end
	if (line_2_pos+1 > vim.fn["line"]('w$')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_low
	end

	cl_extmarks.Edit_extmarks(
								lines_txt[1],
								lines_txt[2],
								line_1_pos,
								line_2_pos
							 )

end

-- update cheat line contence based on new cursor position and/or parameters
function M.Update_cheat_line ()
	if (cl_options.operation_mode == 1) then
		Update_word_based_cheat_line()
	else
		Update_char_based_cheat_line()
	end
end

local cheat_line_augroup_id = -1

function Enable_word_based_cheat_line ()
	if (cl_options_wb.point_to_begining_default_val == 1) then
		cl_options_wb.point_to_begining = true
	elseif (cl_options_wb.point_to_begining_default_val == 0) then
		cl_options_wb.point_to_begining = false
	end

	if (cl_options.cheat_line_enabled == true) then
		return
	end
	cl_options.cheat_line_enabled = true

	-- do nothing if there's not enough space for cheat-line
	
	if (vim.api.nvim_buf_line_count(0) < 3) then
		return
	end

	local current_line_pos = vim.api.nvim_win_get_cursor(0)[1]-1	--getting line number
	local cursor_position = vim.api.nvim_win_get_cursor(0)[2]		--getting cursor position on the line

	-- generate text for cheat lines
	local lines_txt = cl_word_based_gen.Generate_cheat_line_text(
																	current_line_pos,
																	cursor_position
																)

	local line_1_pos = current_line_pos+cl_options_wb.line_1_relative_pos
	local line_2_pos = current_line_pos+cl_options_wb.line_2_relative_pos

	local lines_total = vim.fn['line']('w$')-vim.fn["line"]('w0')+1

	-- catch edge cases when cheat lines goes beyond the scopes of the buffer
	if (line_1_pos+1 < vim.fn['line']('w0')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn['line']('w$')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_low
	end
	if (line_1_pos+1 < vim.fn['line']('w0')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn['line']('w$')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_low
	end

	cl_extmarks.Create_extmarks(
								lines_txt[1],
								lines_txt[2],
								line_1_pos,
								line_2_pos
							   )

	Create_autocommands()
end

function Enable_char_based_cheat_line ()
	if (cl_options.cheat_line_enabled == true) then
		return
	end
	cl_options.cheat_line_enabled = true

	-- do nothing if there's not enough space for cheat-line
	
	if (vim.api.nvim_buf_line_count(0) < 3) then
		return
	end

	local line_1 = cl_str_manipulations.Stretch_to_the_buffer("line_1")
	local line_2 = cl_str_manipulations.Stretch_to_the_buffer("line_2")

	local current_line_pos = vim.api.nvim_win_get_cursor(0)[1]-1	--getting line number
	local cursor_position = vim.api.nvim_win_get_cursor(0)[2]		--getting cursor position on the line

	local lines_txt = cl_char_based_gen.Generate_cheat_line_text(
																	current_line_pos,
																	cursor_position
																)

	local line_1_pos = current_line_pos+cl_options_wb.line_1_relative_pos
	local line_2_pos = current_line_pos+cl_options_wb.line_2_relative_pos

	local lines_total = vim.fn['line']('w$')-vim.fn["line"]('w0')+1

	-- catch edge cases when cheat lines goes beyond the scopes of the buffer
	if (line_1_pos+1 < vim.fn['lines']('w0')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn['lines']('w$')) then
		line_1_pos = current_line_pos + cl_options_wb.line_1_pos_if_to_low
	end
	if (line_1_pos+1 < vim.fn['lines']('w0')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_high
	end
	if (line_1_pos+1 > vim.fn['lines']('w$')) then
		line_2_pos = current_line_pos + cl_options_wb.line_2_pos_if_to_low
	end

	cl_extmarks.Create_extmarks(
								lines_txt[1],
								lines_txt[2],
								line_1_pos,
								line_2_pos
							   )

	Create_autocommands()
end

function M.Enable_cheat_line ()
	if (cl_options.cheat_line_op_mode_default ~= -1) then
		cl_options.operation_mode = cl_options.cheat_line_op_mode_default
	end

	if (cl_options.operation_mode == 1) then
		Enable_word_based_cheat_line()
	else
		Enable_char_based_cheat_line()
	end
end

function M.Disable_cheat_line ()
	if (cl_options.cheat_line_enabled == false) then
		return
	end

	cl_options.cheat_line_enabled = false

	cl_extmarks.Delete_extmarks()
	Delete_autocommands()
end

function M.Toggle_cheat_line ()
	if (cl_options.cheat_line_enabled == false) then
		M.Enable_cheat_line()
	else
		M.Disable_cheat_line()
	end
end

-- create autocommands for updating cheat line properly
function Create_autocommands ()

	-- groups for easier autocommands management
	cheat_line_augroup_id = vim.api.nvim_create_augroup("Cheat-line-autocmds", {clear = false})

	-- upon leaving buffer clean up existing extmarks so that they don't stay there indefinately
	vim.api.nvim_create_autocmd(
								{ 'BufLeave' },
								{
									group = cheat_line_augroup_id,
									callback = function(ev)
										cl_extmarks.Delete_extmarks()
										cl_options.cheat_line_enabled = false
									end
								}
							   )

	-- upon entering new buffer rewrite extmarks by using Enable method so cheat line appears in new buffer immediately
	vim.api.nvim_create_autocmd(
								{ 'BufEnter' },
								{
									group = cheat_line_augroup_id,
									callback = function(ev)
										M.Enable_cheat_line()
									end
								}
							   )

	-- upon any curosr movement update cheat line extmarks 
	vim.api.nvim_create_autocmd(
								{ 'CursorMoved', 'CursorMovedI' },
								{
									group = cheat_line_augroup_id,
									callback = function(ev)
										M.Update_cheat_line()
									end
								}
							   )
	vim.api.nvim_create_autocmd(
								{ 'ColorScheme' },
								{
									group = cheat_line_augroup_id,
									callback = function(ev)
										cl_highlight.Create_cheat_line_highlights_if_not_defined()
									end
								}
							   )
	
end

-- delete autocommands
function Delete_autocommands ()
	if (cheat_line_augroup_id ~= -1) then
		vim.api.nvim_del_augroup_by_id(cheat_line_augroup_id)
		cheat_line_augroup_id = -1
	end
end

function Enable_default_mappings ()
    vim.keymap.set("n", "<leader>c", "<CMD>CheatLineToggle<CR>", { silent = false })
    vim.keymap.set("n", "<leader>x", "<CMD>CheatLineSwitchOperationMode<CR>", { silent = false })
end

-- switch between cheat line pointing to beginning and ending of cheat line
function M.Change_pointing_mode ()
	if (cl_options_wb.point_to_begining == true) then
		cl_options_wb.point_to_begining = false
	else
		cl_options_wb.point_to_begining = true
	end
	M.Update_cheat_line()
end

function M.Switch_operation_mode ()
	if (cl_options.cheat_line_enabled ~= true) then
		return
	end

	if (cl_options.operation_mode == 1) then
		cl_options.operation_mode = 2
	else
		cl_options.operation_mode = 1
	end
	M.Update_cheat_line()
end

function M.setup (opts)
	cl_options = vim.tbl_deep_extend('force', cl_options, opts or {})
	cl_highlight.Create_cheat_line_highlights()

	if (cl_options.enable_default_mappings == true) then
		Enable_default_mappings()
	end

end

return M 
