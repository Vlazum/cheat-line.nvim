local cl_str_func = require("cheat-line.cl_str_manipulations")
local cl_options = require("cheat-line.cl_options").config.word_based

local M = {}

-- process word marking the beginning and the end of a given word leaving out everything else
-- Example:
-- in:	This_is_a_word
-- out:	B            E
--
function Refine_word (input_word)
	local word_len = vim.fn['strchars'](input_word)
	if ( word_len == 1 ) then
		return "D"
	end

	local result = "B"
	local iter = 1
	local iterations = word_len

	while (iter < (iterations-1)) do
		result = result .. ' '
		--result = result .. input_word[(iter%#input_word)+1]
		iter = iter + 1
	end
	result = result .. 'E'

	return result
end

-- process divider marking the beginning and the end of each whitespace separated segment in a given divider leaving out everything else
-- Example:
--
-- in:	.*%@#   "&&&&&"
-- out:	B   E   B     E
--
function Refine_divider (input_divider)
	local whitespaces = vim.fn['split'](input_divider, '\\S\\+')
	local non_whitespaces = vim.fn['split'](input_divider, '\\s\\+')

	-- catch stinky edgecases
	if (#whitespaces == 0 ) then
		return Refine_word(non_whitespaces[1])
	end
	if (#non_whitespaces == 0 ) then
		return input_divider
	end

	local first_char_whitespace = -1
	if (string.sub(whitespaces[1],1,1) == string.sub(input_divider,1,1)) then
		first_char_whitespace = 1
	else
		first_char_whitespace = 0
	end


	local iter = 0
	local iterations = #whitespaces + #non_whitespaces
	local whitespace_iter = 1
	local non_whitespace_iter = 1
	local result = ""

	while (iter < iterations) do
		if ((iter % 2) ~= first_char_whitespace) then
			result = result .. whitespaces[whitespace_iter]
			whitespace_iter = whitespace_iter + 1 
		else
			result = result .. Refine_word(non_whitespaces[non_whitespace_iter])
			non_whitespace_iter = non_whitespace_iter + 1 
		end
		iter = iter + 1
	end

	return result
end

-- process line marking start and end of each word and cursor position leaving out everything else  
-- *B for beginning 
-- *E for ending 
-- *D for both 
--
-- Example:
--
-- in:	const int & number = 10000; 
-- out:	B   E B E D B    E D B   ED
--
function Process_line_wb (input_line)
	
	--input_line = Replace_tab_with_whitespaces(input_line)

	local words = vim.fn['split'](input_line, "\\W\\+")
	local dividers = vim.fn['split'](input_line, "\\w\\+")

	-- deal with edge cases 
	if ( vim.fn['strchars'](input_line) == 0) then
		return cl_str_func.Stretch_to_the_buffer('')
	end
	if ( #words == 0) then
		return cl_str_func.Stretch_to_the_buffer(Refine_divider(dividers[1]))
	end
	if ( #dividers == 0) then
		return cl_str_func.Stretch_to_the_buffer(Refine_word(words[1]))
	end

	local first_char_is_a_word = -1
	if (string.sub(words[1],1,1) == string.sub(input_line,1,1)) then
		first_char_is_a_word = 1
	else
		first_char_is_a_word = 0
	end

	local result = ""

	local iter = 0
	local iterations = #words + #dividers
	local word_iter = 1
	local divider_iter = 1
	while (iter < iterations) do
		if ( (iter % 2) ~= first_char_is_a_word ) then
			result = result .. Refine_word(words[word_iter])
			word_iter = word_iter + 1
		else
			result = result .. Refine_divider(dividers[divider_iter])
			divider_iter = divider_iter + 1
		end
		iter = iter + 1
	end

	result = cl_str_func.Stretch_to_the_buffer(result)

	return result
end


function Split_pivot_points_between_two_lines_wb (processed_string, seek_char)
	local iter = 0
	local iterations = string.len(processed_string)
	
	local char_hit = 0
	local cursor_relative_pos = 0
	
	local procsd_line_1 = ''
	local procsd_line_2 = ''
	local iter_char = ''

	while (iter < iterations) do
		iter_char = string.sub(processed_string,iter+1,iter+1)
	
		if (iter_char == seek_char) or (iter_char == 'D') then
			if (char_hit%2 ==  0) then
				procsd_line_1 = procsd_line_1 .. 'D'
				procsd_line_2 = procsd_line_2 .. ' '
			else
				procsd_line_1 = procsd_line_1 .. ' '
				procsd_line_2 = procsd_line_2 .. 'D'
			end
			char_hit = char_hit + 1
		elseif (iter_char == 'C') then
			cursor_relative_pos = char_hit
			if (char_hit%2 ==  0) then
				procsd_line_1 = procsd_line_1 .. 'D'
				procsd_line_2 = procsd_line_2 .. ' '
			else
				procsd_line_1 = procsd_line_1 .. ' '
				procsd_line_2 = procsd_line_2 .. 'D'
			end
			char_hit = char_hit + 1
		else
			procsd_line_1 = procsd_line_1 .. iter_char
			procsd_line_2 = procsd_line_2 .. iter_char
		end
	
		iter = iter + 1
	end

	return procsd_line_1, procsd_line_2, cursor_relative_pos
end 

function Generate_first_cheat_line_wb (procsd_line_1, cursor_relative_pos)
	local iter = 0
	local iterations = string.len(procsd_line_1)
	local char_hit = 0
	local relative_num = 0
	local tmp_array = {'',''}
	local l1_hl_group_iter = 0
	local skip_char = 0
	local iter_char = ""
	local cheat_line_1 = {}

	while (iter < iterations) do
		iter_char = string.sub(procsd_line_1,iter+1,iter+1)
		if (iter_char == 'D') then
			-- calculate abs value of pivot point position 
			-- make it mode 100 to avoid edge cases
			relative_num = math.abs(char_hit-cursor_relative_pos)%100
			char_hit = char_hit + 2
	
			if (relative_num == 0 and not cl_options.show_index_0) then
				tmp_array[1] = tmp_array[1] .. ' '
			else
				tmp_array[1] = tmp_array[1] .. relative_num
			end
	
			if (cl_options.index_0_on_line == -1) then
				tmp_array[2] = cl_options.line_1_hl_groups[(l1_hl_group_iter%2)+1]
			else
				if ((cursor_relative_pos % 2) ~= cl_options.index_0_on_line) then
					tmp_array[2] = cl_options.line_1_hl_groups[(l1_hl_group_iter%2)+1]
				else
					tmp_array[2] = cl_options.line_2_hl_groups[(l1_hl_group_iter%2)+1]
				end
			end 
	
			cheat_line_1[l1_hl_group_iter+1] = tmp_array
			tmp_array = {'', ''}
	
	
			l1_hl_group_iter = l1_hl_group_iter + 1
	
			skip_char = 1
			if (relative_num - (relative_num%10) == 0) then
				tmp_array[1] = tmp_array[1] .. ' '
			end
		else
			if (skip_char == 1) then
				skip_char = 0
				if (iter_char == '	') then
					tmp_array[1] = tmp_array[1] .. iter_char
				end
			else
				tmp_array[1] = tmp_array[1] .. iter_char
			end
		end
		iter = iter + 1 
	end
	if (cl_options.index_0_on_line == -1) then
		tmp_array[2] = cl_options.line_1_hl_groups[(l1_hl_group_iter%2)+1]
	else
		if ((cursor_relative_pos % 2) ~= cl_options.index_0_on_line) then
			tmp_array[2] = cl_options.line_1_hl_groups[(l1_hl_group_iter%2)+1]
		else
			tmp_array[2] = cl_options.line_2_hl_groups[(l1_hl_group_iter%2)+1]
		end
	end 

	cheat_line_1[l1_hl_group_iter+1] = tmp_array

	return cheat_line_1
end

function Generate_second_cheat_line_wb (procsd_line_2, cursor_relative_pos)
	local iter = 0
	local iterations = string.len(procsd_line_2)
	local char_hit = 0
	local relative_num = 0
	local l2_hl_group_iter = 0
	local skip_char = 0
	local tmp_array = {'',''}
	local cheat_line_2 = {}

	while (iter < iterations) do
		iter_char = string.sub(procsd_line_2,iter+1,iter+1)
		if (iter_char == 'D') then
			-- calculate abs value of pivot point position 
			-- make it mode 100 to avoid edge cases
			relative_num = math.abs(char_hit-cursor_relative_pos+1)%100
			char_hit = char_hit + 2
	
			if (relative_num == 0 and not cl_options.show_index_0) then
				tmp_array[1] = tmp_array[1] .. ' '
			else
				tmp_array[1] = tmp_array[1] .. relative_num
			end
			--tmp_array[1] = tmp_array[1] .. relative_num
	
			if (cl_options.index_0_on_line == -1) then
				tmp_array[2] = cl_options.line_2_hl_groups[(l2_hl_group_iter%2)+1]
			else
				if ((cursor_relative_pos % 2) ~= cl_options.index_0_on_line) then
					tmp_array[2] = cl_options.line_2_hl_groups[(l2_hl_group_iter%2)+1]
				else
					tmp_array[2] = cl_options.line_1_hl_groups[(l2_hl_group_iter%2)+1]
				end
			end 
	
			cheat_line_2[l2_hl_group_iter+1] = tmp_array
			tmp_array = {'', ''}
	
			l2_hl_group_iter = l2_hl_group_iter + 1
	
			skip_char = 1
			if (relative_num - (relative_num%10) == 0) then
				tmp_array[1] = tmp_array[1] .. ' '
			end
		else
			if (skip_char == 1) then
				skip_char = 0
				if (iter_char == '	') then
					tmp_array[1] = tmp_array[1] .. iter_char
				end
			else
				tmp_array[1] = tmp_array[1] .. iter_char
			end
		end
		iter = iter + 1 
	end

	if (cl_options.index_0_on_line == -1) then
		tmp_array[2] = cl_options.line_2_hl_groups[(l2_hl_group_iter%2)+1]
	else
		if ((cursor_relative_pos % 2) ~= cl_options.index_0_on_line) then
			tmp_array[2] = cl_options.line_2_hl_groups[(l2_hl_group_iter%2)+1]
		else
			tmp_array[2] = cl_options.line_1_hl_groups[(l2_hl_group_iter%2)+1]
		end
	end 

	cheat_line_2[l2_hl_group_iter+1] = tmp_array

	return cheat_line_2
end

-- Generate virtual text for cheat line 
--
-- Example:
-- considering that cursor in on the letter 'o' in 'people'
--
-- in:	The kambocha mushrom people sitting around all day...
-- out: 4            2         0            2          4
--          3                1      1              3      5
--
function M.Generate_cheat_line_text (
										cursor_line,
										cursor_pos
									)
	local cursor_string = vim.fn['getline']('.')
	local processed_string = Process_line_wb(cursor_string)
	
	local seek_char = 'N'
	if (cl_options.point_to_begining == true) then
		seek_char = 'B'
		processed_string = string.gsub(processed_string, 'E', ' ')
	else
		seek_char = 'E'
		processed_string = string.gsub(processed_string, 'B', ' ')
	end

	if (string.sub(processed_string, cursor_pos+1, cursor_pos+1) == '	') then
		processed_string = cl_str_func.Replace_char_in_string (processed_string, cursor_pos, 'C')
		local iter = 1 
		while iter < vim.o.tabstop do
			processed_string = cl_str_func.Insert_char_in_string (processed_string, cursor_pos, ' ')
			iter = iter + 1
		end
	else
		processed_string = cl_str_func.Replace_char_in_string (processed_string, cursor_pos, 'C')
	end
	
	
	local pivots = 1 
	for it in string.gmatch(processed_string, seek_char) do
		pivots = pivots + 1
	end
	for it in string.gmatch(processed_string, 'D') do
		pivots = pivots + 1
	end
	
	if (pivots == 1) then
		return {{{''}}, {{''}}}
	end

	local procsd_line_1, procsd_line_2, cursor_relative_pos = Split_pivot_points_between_two_lines_wb(processed_string, seek_char)
	
	local cheat_line_1 = Generate_first_cheat_line_wb (procsd_line_1, cursor_relative_pos)
	local cheat_line_2 = Generate_second_cheat_line_wb(procsd_line_2, cursor_relative_pos)
	
	if ((cursor_relative_pos % 2) ~= cl_options.index_0_on_line) then 
		return { cheat_line_2, cheat_line_1 }
	end
	return { cheat_line_1, cheat_line_2 }

end

return M
