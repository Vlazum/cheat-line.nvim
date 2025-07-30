local M = {}

-- stretch input string with whitespaces so it's length matches current buffer width
function M.Stretch_to_the_buffer (input)
	local result = input
	local iter = vim.fn['strdisplaywidth'](result)
	local iterations = vim.fn['winwidth'](0)
	for i = iter, iterations do
		result = result .. ' '
	end
	return result
end

function M.Replace_char_in_string (
									input_string,
									char_index,
									new_char
								  )
	local result = string.sub(input_string, 1, char_index) ..
				   new_char ..
				   string.sub(input_string, char_index+2, #input_string)
	return result
end

function M.Insert_char_in_string (
									input_string,
									char_index,
									new_char
								 )
	local result = string.sub(input_string, 1, char_index) ..
				   new_char ..
				   string.sub(input_string, char_index+1, #input_string)
	return result
end

return M
