local cl_str_func = require("cheat-line.cl_str_manipulations")
local cl_options = require("cheat-line.cl_options").config.char_based

local M = {}

-- process input line into a line only containing pivot points and without tabs
-- Example: 
-- in	:		Hypochrit, lunatic, fanatic, heretic
-- out	:	D  DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
function Process_line_cb (input_line, cursor_pos)
	local iter = 0
	local iterations = vim.fn['strchars'](input_line)
	local char_iter = ''
	local char_offset = 0

	local processed_string = ""

	while (iter < iterations) do
		char_iter = string.sub(input_line,iter+1,iter+1)
		if (char_iter == '	') then
			local it = 1
			local it_num = vim.o.tabstop - (char_offset % vim.o.tabstop)
			--print (it .. ' ' .. vim.o.tabstop - (char_offset % vim.o.tabstop))
			while it < it_num do
				processed_string = processed_string .. ' '
				it = it + 1
				char_offset = char_offset + 1
			end
			if (iter == cursor_pos) then
				processed_string = processed_string .. 'C'
			else
				processed_string = processed_string .. 'D'
			end
		else
			if (iter == cursor_pos) then
				processed_string = processed_string .. 'C'
			else
				processed_string = processed_string .. 'D'
			end
		end
		iter = iter + 1
		char_offset = char_offset + 1
	end

	if (char_offset == 0) then
		return ""
	end

	return  processed_string
end

function Process_line_cb_virtual_mode (input_line, cursor_pos)
	local iter = 0
	local iterations = vim.fn['strchars'](input_line)
	local char_iter = ''
	local char_offset = 0
	local processed_string = ""
--adfasdfasdfads fad fsad fasdf 
	while (iter < iterations) do
		char_iter = string.sub(input_line,iter+1,iter+1)
		if (char_iter == '	') then
			local it = 0
			local it_num = vim.o.tabstop - (char_offset % vim.o.tabstop)
			--print (it .. ' ' .. vim.o.tabstop - (char_offset % vim.o.tabstop))
			while it < it_num do
				if (iter == cursor_pos) then
					processed_string = processed_string .. 'C'
				else
					processed_string = processed_string .. 'D'
				end
				it = it + 1
				char_offset = char_offset + 1
			end
		else
			if (iter == cursor_pos) then
				processed_string = processed_string .. 'C'
			else
				processed_string = processed_string .. 'D'
			end
		end
		iter = iter + 1
		char_offset = char_offset + 1
	end

	return  processed_string
end

function Split_pivot_points_between_two_lines_cb (processed_line)
	local iter = 0
	local iterations = string.len(processed_line)

	local line_1 = ""
	local line_2 = ""
	local pivot_iter = 0
	local relative_pos = 0

	while (iter < iterations) do
		local char_iter = string.sub(processed_line,iter+1,iter+1)
		if (char_iter == 'D') then
			if (pivot_iter % 2) == 0 then
				line_1 = line_1 .. 'D'
				line_2 = line_2 .. ' '
			else
				line_1 = line_1 .. ' '
				line_2 = line_2 .. 'D'
			end
			pivot_iter = pivot_iter + 1
		elseif (char_iter == 'C') then
			if (pivot_iter % 2) == 0 then
				line_1 = line_1 .. 'C'
				line_2 = line_2 .. ' '
			else
				line_1 = line_1 .. ' '
				line_2 = line_2 .. 'C'
			end
			relative_pos = pivot_iter
			pivot_iter = pivot_iter + 1
		else
			line_1 = line_1 .. ' '
			line_2 = line_2 .. ' '
		end
		iter = iter + 1
	end

	return line_1, line_2, relative_pos
end

function Generate_second_cheat_line_cb (processed_line, cursor_relative_pos)
	local iter = 0
	local iterations = string.len(processed_line)

	local char_hit = 0
	local relative_number = 0

	local cheat_line = {}
	local skip_char = 0
	local hl_iter = 0

	local tmp_array = {'', ''}

	while (iter < iterations) do
		char_iter = string.sub(processed_line,iter+1,iter+1)
		if (char_iter == 'D') or (char_iter == 'C') then

			relative_number = char_hit-cursor_relative_pos

			if (math.abs(relative_number) < 10) then
				if (relative_number % 2) ~= 0 then
					tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
					tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
					cheat_line[#cheat_line+1] = tmp_array
					hl_iter = (hl_iter + 1)%2
					tmp_array = {'', ''}
					--cheat_line = cheat_line .. math.abs(relative_number)
				else
					tmp_array[1] = tmp_array[1] .. ' '
					--cheat_line = cheat_line .. ' '
				end
			else
				if (relative_number < -9) then
					if ((math.abs(relative_number)-1)%4) == 0 then
						tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
						tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
						cheat_line[#cheat_line+1] = tmp_array
						hl_iter = (hl_iter + 1)%2
						tmp_array = {'', ''}
						--cheat_line = cheat_line .. math.abs(relative_number)

						skip_char = 1
					else
						if (skip_char == 1) then
							skip_char = 0
						else
							tmp_array[1] = tmp_array[1] .. ' '
							--cheat_line = cheat_line .. ' '
						end
					end
				else
					if (math.abs(relative_number)%4) == 0 then
						tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
						tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
						cheat_line[#cheat_line+1] = tmp_array
						hl_iter = (hl_iter + 1)%2
						tmp_array = {'', ''}
						--cheat_line = cheat_line .. math.abs(relative_number)

						skip_char = 1
					else
						if (skip_char == 1) then
							skip_char = 0
						else
							tmp_array[1] = tmp_array[1] .. ' '
							--cheat_line = cheat_line .. ' '
						end
					end
				end
			end
			char_hit = char_hit + 1

		else
			if (skip_char == 1) then
				skip_char = 0
			else
				tmp_array[1] = tmp_array[1] .. ' '
				--cheat_line = cheat_line .. ' '
			end
		end
		iter = iter + 1
	end

	tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
	cheat_line[#cheat_line+1] = tmp_array

	return cheat_line
end

function Generate_first_cheat_line_cb (processed_line, cursor_relative_pos)
	local iter = 0
	local iterations = string.len(processed_line)

	local char_hit = 0
	local relative_number = 0

	local cheat_line = {}
	local skip_char = 0
	local hl_iter = 0

	local tmp_array = {'', ''}

	while (iter < iterations) do
		char_iter = string.sub(processed_line,iter+1,iter+1)
		if (char_iter == 'D') or (char_iter == 'C') then

			relative_number = char_hit-cursor_relative_pos

			if (math.abs(relative_number) < 10) then
				if (relative_number % 2) == 0 then
					tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
					tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
					cheat_line[#cheat_line+1] = tmp_array
					hl_iter = (hl_iter + 1)%2
					tmp_array = {'', ''}
					--cheat_line = cheat_line .. math.abs(relative_number)
				else
					tmp_array[1] = tmp_array[1] .. ' '
					--cheat_line = cheat_line .. ' '
				end
			else
				if (relative_number < -9) then
					if ((math.abs(relative_number)+1)%4) == 0 then
						tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
						tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
						cheat_line[#cheat_line+1] = tmp_array
						hl_iter = (hl_iter + 1)%2
						tmp_array = {'', ''}
						--cheat_line = cheat_line .. math.abs(relative_number)

						skip_char = 1
					else
						if (skip_char == 1) then
							skip_char = 0
						else
							tmp_array[1] = tmp_array[1] .. ' '
							--cheat_line = cheat_line .. ' '
						end
					end
				else
					if ((math.abs(relative_number)+2)%4) == 0 then
						tmp_array[1] = tmp_array[1] .. math.abs(relative_number)
						tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
						cheat_line[#cheat_line+1] = tmp_array
						hl_iter = (hl_iter + 1)%2
						tmp_array = {'', ''}
						--cheat_line = cheat_line .. math.abs(relative_number)

						skip_char = 1
					else
						if (skip_char == 1) then
							skip_char = 0
						else
							tmp_array[1] = tmp_array[1] .. ' '
							--cheat_line = cheat_line .. ' '
						end
					end
				end
			end
			char_hit = char_hit + 1

		else
			if (skip_char == 1) then
				skip_char = 0
			else
				tmp_array[1] = tmp_array[1] .. ' '
				--cheat_line = cheat_line .. ' '
			end
		end
		iter = iter + 1
	end

	tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
	cheat_line[#cheat_line+1] = tmp_array

	return cheat_line
end

function Generate_cheat_line_cb (processed_line, cursor_pos, cheat_line_id)
	local iter = 0
	local iterations = string.len(processed_line)

	local char_hit = 0
	local relative_number = 0

	local cheat_line = {}
	local skip_char = 0
	local hl_iter = 0

	if (cheat_line_id ~= 1) then
		char_hit = 1
	end

	local tmp_array = {'', ''}

	while (iter < iterations) do
		char_iter = string.sub(processed_line,iter+1,iter+1)
		if (char_iter == 'D') or (char_iter == 'C') then

			relative_number = math.abs(char_hit-cursor_pos)%100
			tmp_array[1] = tmp_array[1] .. relative_number
			if (cheat_line_id == 1) ~= ((cursor_pos%2)==0) then
				tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
			else
				tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
			end
			cheat_line[#cheat_line+1] = tmp_array
			hl_iter = (hl_iter+1)%2
			tmp_array = {'', ''}

			if (relative_number - (relative_number%10)) ~= 0 then
				skip_char = 1
			end

			char_hit = char_hit + 2

		else
			if (skip_char == 1) then
				skip_char = 0
			else
				tmp_array[1] = tmp_array[1] .. ' '
				--cheat_line = cheat_line .. ' '
			end
		end
		iter = iter + 1
	end

	if (cheat_line_id == 1) then
		tmp_array[2] = cl_options.line_1_hl_groups[hl_iter+1]
	else
		tmp_array[2] = cl_options.line_2_hl_groups[hl_iter+1]
	end

	cheat_line[#cheat_line+1] = tmp_array

	return cheat_line
end

function M.Generate_cheat_line_text (
										cursor_line,
										cursor_pos
									)
	local cursor_string = vim.fn['getline']('.')
	local processed_line = ""; 

	if (vim.o.virtualedit == 'all') then
		processed_line = Process_line_cb_virtual_mode(cursor_string, cursor_pos)
		if (processed_line == '') then
			return { {{''}} , {{''} }}
		end
		processed_line = cl_str_func.Stretch_to_the_buffer(processed_line)
	else
		processed_line = Process_line_cb(cursor_string, cursor_pos)
		if (processed_line == '') then
			return { {{''}} , {{''} }}
		end
		processed_line = cl_str_func.Stretch_to_the_buffer(processed_line)
	end

	local line_1, line_2, cursor_relative_pos = Split_pivot_points_between_two_lines_cb (processed_line)

	local cheat_line_1 = {} 
	local cheat_line_2 = {}

	if (cl_options.include_less_pivot_points == true) then
		cheat_line_1 = Generate_first_cheat_line_cb (processed_line, cursor_relative_pos)
		cheat_line_2 = Generate_second_cheat_line_cb (processed_line, cursor_relative_pos)
		return {
					cheat_line_1,
					cheat_line_2
			   }
	else
		cheat_line_1 = Generate_cheat_line_cb (line_1, cursor_relative_pos, 1)
		cheat_line_2 = Generate_cheat_line_cb (line_2, cursor_relative_pos, 2)
		if (cursor_relative_pos%2) == 0 then
			return {
						cheat_line_1,
						cheat_line_2
				   }
		else
			return {
						cheat_line_2,
						cheat_line_1
				   }
		end
	end

end

return M
