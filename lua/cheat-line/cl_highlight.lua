local M = {}

local cl_options = require("cheat-line.cl_options").config
local cl_options_wb = cl_options.word_based
local cl_options_cb = cl_options.char_based

-- create new custom highlight groups for cheat line
function M.Create_cheat_line_highlights ()
	-- create highlight for word based cheat line generation
	vim.cmd( ":highlight CheatLine1Primary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_1_primary)
	vim.cmd( ":highlight CheatLine1Secondary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_1_secondary)

	vim.cmd( ":highlight CheatLine2Primary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_2_primary)
	vim.cmd( ":highlight CheatLine2Secondary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_2_secondary)


	-- create highlight for char based cheat line generation
	vim.cmd( ":highlight CheatLine1Primary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_1_primary)
	vim.cmd( ":highlight CheatLine1Secondary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_1_secondary)

	vim.cmd( ":highlight CheatLine2Primary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_2_primary)
	vim.cmd( ":highlight CheatLine2Secondary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_2_secondary)
end


function M.Create_cheat_line_highlights_if_not_defined ()
	print ('Create_cheat_line_highlights_if_not_defined function call')
	-- create highlight for word based cheat line generation
	if (vim.fn['hlexists']('CheatLine1Primary')) then
		vim.cmd( ":highlight CheatLine1Primary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_1_primary)
	end
	if (vim.fn['hlexists']('CheatLine1Secondary')) then
		vim.cmd( ":highlight CheatLine1Secondary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_1_secondary)
	end

	if (vim.fn['hlexists']('CheatLine2Primary')) then
		vim.cmd( ":highlight CheatLine2Primary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_2_primary)
	end
	if (vim.fn['hlexists']('CheatLine2Secondary')) then
		vim.cmd( ":highlight CheatLine2Secondary "	.. cl_options_wb.custom_hl_group_settings.cheat_line_2_secondary)
	end


	-- create highlight for char based cheat line generation
	if (vim.fn['hlexists']('CheatLine1Primary_alt')) then
		vim.cmd( ":highlight CheatLine1Primary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_1_primary)
	end
	if (vim.fn['hlexists']('CheatLine1Secondary_alt')) then
		vim.cmd( ":highlight CheatLine1Secondary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_1_secondary)
	end

	if (vim.fn['hlexists']('CheatLine2Primary_alt')) then
		vim.cmd( ":highlight CheatLine2Primary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_2_primary)
	end
	if (vim.fn['hlexists']('CheatLine2Secondary_alt')) then
		vim.cmd( ":highlight CheatLine2Secondary_alt "	.. cl_options_cb.custom_hl_group_settings.cheat_line_2_secondary)
	end
end

return M
