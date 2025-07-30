local M = {}

local extmark_namespace = vim.api.nvim_create_namespace('cheat-line-ns')

local line_1_id = -1
local line_2_id = -1

-- create cheat line extmarks
function M.Create_extmarks ( line_1_txt, line_2_txt, line_1_pos, line_2_pos)

	line_1_id = vim.api.nvim_buf_set_extmark(
												0,					--place mark in current buffer
												extmark_namespace,	--specify namespace
												line_1_pos,			--specify line position (row)
												0,					--specify line position (column)
												{
													virt_text = line_1_txt,		--set virtual text
													virt_text_pos = "overlay"	--specify text application style
												}
											) 

	line_2_id = vim.api.nvim_buf_set_extmark(
												0,					--place mark in current buffer
												extmark_namespace,	--specify namespace
												line_2_pos,			--specify line position (row)
												0,					--specify line position (column)
												{
													virt_text = line_2_txt,		--set virtual text
													virt_text_pos = 'overlay'	--specify text application style
												}
											) 
end

-- edit existing cheat line extmarks
function M.Edit_extmarks ( line_1_txt, line_2_txt, line_1_pos, line_2_pos)

	vim.api.nvim_buf_set_extmark(
									0,					--place mark in current buffer
									extmark_namespace,	--specify namespace
									line_1_pos,			--specify line position (row)
									0,					--specify line position (column)
									{
										id = line_1_id,
										virt_text = line_1_txt,		--set virtual text
										virt_text_pos = "overlay"	--specify text application style
									}
								) 

	vim.api.nvim_buf_set_extmark(
									0,					--place mark in current buffer
									extmark_namespace,	--specify namespace
									line_2_pos,			--specify line position (row)
									0,					--specify line position (column)
									{
										id = line_2_id,
										virt_text = line_2_txt,		--set virtual text
										virt_text_pos = 'overlay'	--specify text application style
									}
								) 
end

-- dlete cheat line extmarks
function M.Delete_extmarks ()
	if (line_1_id ~= -1) then
		vim.api.nvim_buf_del_extmark(0, extmark_namespace, line_1_id)
		line_1_id = -1
	end
	if (line_2_id ~= -1) then
		vim.api.nvim_buf_del_extmark(0, extmark_namespace, line_2_id)
		line_2_id = -1
	end
end

return M
