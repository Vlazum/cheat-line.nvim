let g:cheat_line_config = {
\							'point_to_first_char' : 1,
\							'L1_highlight_group' : 'Ignore',
\							'L2_highlight_group' : 'Ignore',
\						    'L1_relative_pos' : -1,
\						    'L2_relative_pos' : -2,	
\						    'L1_pos_if_too_high' : 2,	
\						    'L2_pos_if_too_high' : 1,	
\						    'L1_pos_if_too_low' : -1,	
\						    'L2_pos_if_too_low' : -2,	
\						  }

function cheat_line#Setup (input_config)
	for key in keys(g:cheat_line_config)
		if has_key(a:input_config, key)
			let g:cheat_line_config[key] = a:input_config[key]
		endif
	endfor
endfunction

let g:cheat_line_enabled = 0 
let s:cheat_line_enabled = 0 

let s:mark_ns = nvim_create_namespace('cheat_line')
let s:mark_id_1 = 0
let s:mark_id_2 = 0

function s:Refine_divider (divider)
	if len(a:divider) == 1
		if a:divider[0] == ' '
			return [' ']
		else
			if a:divider[0] == '	'
				return '	'
			else
				return ['D']
			endif
		endif
	endif

	let l:result = []

	let l:iter = 0
	let l:iterations = strchars(a:divider)

	let l:on_a_word = 0
	
	while l:iter < l:iterations

		if a:divider[l:iter] == "	"
			if l:on_a_word == 1
				if l:result[l:iter-1] == 'B'
					let l:result[l:iter-1] = 'D'
				else
					let l:result[l:iter-1] = 'E'
				endif
				let l:on_a_word = 0
			endif

	
			let l:result = add(l:result, "	")
	
		else 

			if a:divider[l:iter] == " "
				if l:on_a_word == 1
					if l:result[l:iter-1] == 'B'
						let l:result[l:iter-1] = 'D'
					else
						let l:result[l:iter-1] = 'E'
					endif
					let l:on_a_word = 0
				endif
				let l:result = add(l:result, " ")
			else
				if l:on_a_word == 0
					let l:result = add(l:result, "B")
					let l:on_a_word = 1
				else
					let l:result = add(l:result, "-")
				endif
			endif

		endif
	
		let l:iter = l:iter + 1
	endwhile

	if (l:result[l:iterations-1] != '	') && (l:result[l:iterations-1] != ' ')
		if (l:result[l:iterations-1] == 'B')
			let l:result[l:iterations-1] = 'D'
		else 
			let l:result[l:iterations-1] = 'E'
		endif
	endif
	
	return l:result
endfunction

function s:Refine_word(word)

	let l:iterations = strchars(a:word)
	if l:iterations == 1
		return ['D']
	endif 

	let l:result = ['B']

	let l:iter = 2

	while l:iter < l:iterations
		let l:result = add(l:result, ' ')
		let l:iter = l:iter + 1
	endwhile

	let l:result = add(l:result, 'E')

	return l:result

endfunction

function s:Get_number_of_digits_in_a_number(number)
	let l:result = 1
	let l:num = a:number
	while ((l:num / 10) >= 1)
		let l:num = l:num / 10
		let l:result = l:result + 1
	endwhile
	return l:result
endfunction

function s:Generate_cheat_lines(line_num)
	let l:result_1 = ''
	let l:result_2 = ''
	let l:seek_char = 'N'
	if g:cheat_line_config['point_to_first_char'] == '1'
		let l:seek_char = 'B'
	else
		let l:seek_char = 'E'
	endif
	let l:current_line = getline(a:line_num)
	let l:line_size = strchars(l:current_line)


	" get words and dividers from the string
	let l:words = split(l:current_line, '\W\+',)
	let l:dividers = split(l:current_line, '\k\+',)
	let l:segmentated_string = []


	
	" if the string is not empty, 
	if len(l:words) > 0

		let l:first_char_is_a_word = -1
		let l:last_char_is_a_word = -1

		if l:current_line[0] == l:words[0][0]
			let l:first_char_is_a_word = 1
		else
			let l:first_char_is_a_word = 0
		endif
		
		"================================================================"
		"let l:real_last_char = l:current_line[l:line_size-1]		     "
		"let l:last_word = l:words[len(l:words)-1]                       "
		"let l:word_last_char = l:last_word[strchars(l:last_word)-1]     "
		"                                                                "
		"if l:real_last_char == l:word_last_char                         "
		"	let l:def = 'last character is a word'                       "
		"else                                                            "
		"	let l:def = 'last character is not a word'                   "
		"endif                                                           "
		"================================================================"
		
		if l:current_line[l:line_size-1] == l:words[len(l:words)-1][strchars(l:words[len(l:words)-1])-1]
			let l:last_char_is_a_word = 1
		else
			let l:last_char_is_a_word = 0
		endif
		
		let segmentated_string = []

		" combine dividers and words into one array
		if first_char_is_a_word == 1
			let l:segmentated_string = []

			let l:iterations = 0
			if len(l:words) < len(l:dividers)
				let l:iterations = len(l:words)
			else
				let l:iterations = len(l:dividers)
			endif

			let l:iter = 0
			while l:iter < l:iterations
				"let l:segmentated_string = add(l:segmentated_string, l:words[l:iter])
				let l:refined_word = s:Refine_word(l:words[l:iter])

				let l:iter_2 = 0
				let l:iterations_2 = len(l:refined_word)
				while l:iter_2 < l:iterations_2 
					let l:segmentated_string = add(l:segmentated_string, l:refined_word[l:iter_2])
					let l:iter_2 = l:iter_2 + 1
				endwhile

				"let l:segmentated_string = add(l:segmentated_string, l:dividers[l:iter])
				let l:refined_divider = s:Refine_divider(l:dividers[l:iter])

				let l:iter_2 = 0
				let l:iterations_2 = len(l:refined_divider)
				while l:iter_2 < l:iterations_2 
					let l:segmentated_string = add(l:segmentated_string, l:refined_divider[l:iter_2])
					let l:iter_2 = l:iter_2 + 1
				endwhile

				let l:iter = l:iter + 1
			endwhile

			if len(l:words) == len(l:dividers)
			else
				if l:last_char_is_a_word == 1
					"let l:segmentated_string = add(l:segmentated_string, l:words[l:iter])
					let l:refined_word = s:Refine_word(l:words[l:iter])
					
					let l:iter_2 = 0
					let l:iterations_2 = len(l:refined_word)
					while l:iter_2 < l:iterations_2 
						let l:segmentated_string = add(l:segmentated_string, l:refined_word[l:iter_2])
						let l:iter_2 = l:iter_2 + 1
					endwhile
				else
					"let l:segmentated_string = add(l:segmentated_string, l:dividers[l:iter])
					let l:refined_divider = s:Refine_divider(l:dividers[l:iter])
					
					let l:iter_2 = 0
					let l:iterations_2 = len(l:refined_divider)
					while l:iter_2 < l:iterations_2 
						let l:segmentated_string = add(l:segmentated_string, l:refined_divider[l:iter_2])
						let l:iter_2 = l:iter_2 + 1
					endwhile
					endif
			endif

		else
			let l:segmentated_string = []

			let l:iterations = 0
			if len(l:words) < len(l:dividers)
				let l:iterations = len(l:words)
			else
				let l:iterations = len(l:dividers)
			endif

			let l:iter = 0
			while l:iter < l:iterations
				"let l:segmentated_string = add(l:segmentated_string, l:dividers[l:iter])
				let l:refined_divider = s:Refine_divider(l:dividers[l:iter])

				let l:iter_2 = 0
				let l:iterations_2 = len(l:refined_divider)
				while l:iter_2 < l:iterations_2 
					let l:segmentated_string = add(l:segmentated_string, l:refined_divider[l:iter_2])
					let l:iter_2 = l:iter_2 + 1
				endwhile

				"let l:segmentated_string = add(l:segmentated_string, l:words[l:iter])
				let l:refined_word = s:Refine_word(l:words[l:iter])

				let l:iter_2 = 0
				let l:iterations_2 = len(l:refined_word)
				while l:iter_2 < l:iterations_2 
					let l:segmentated_string = add(l:segmentated_string, l:refined_word[l:iter_2])
					let l:iter_2 = l:iter_2 + 1
				endwhile

				let l:iter = l:iter + 1
			endwhile

			if len(l:words) == len(l:dividers)
			else
				if l:last_char_is_a_word == 1
					"let l:segmentated_string = add(l:segmentated_string, l:words[l:iter])
					let l:refined_word = s:Refine_word(l:words[l:iter])
					
					let l:iter_2 = 0
					let l:iterations_2 = len(l:refined_word)
					while l:iter_2 < l:iterations_2 
						let l:segmentated_string = add(l:segmentated_string, l:refined_word[l:iter_2])
						let l:iter_2 = l:iter_2 + 1
					endwhile
				else
					"let l:segmentated_string = add(l:segmentated_string, l:dividers[l:iter])
					let l:refined_divider = s:Refine_divider(l:dividers[l:iter])
					
					let l:iter_2 = 0
					let l:iterations_2 = len(l:refined_divider)
					while l:iter_2 < l:iterations_2 
						let l:segmentated_string = add(l:segmentated_string, l:refined_divider[l:iter_2])
						let l:iter_2 = l:iter_2 + 1
					endwhile
					endif
			endif

		endif


		let l:cursor_position = nvim_win_get_cursor(0)[1]

		let l:cursor_on_tab = 0
		if l:segmentated_string[l:cursor_position] == '	'
			let l:cursor_on_tab = 1
			"call insert(l:segmentated_string, l, l:cursor_position)
			let l:iter = 1
			while l:iter < &l:tabstop
				call insert(l:segmentated_string, ' ', l:cursor_position)
				let l:iter = l:iter + 1
				let l:cursor_position = l:cursor_position + 1
			endwhile
		endif

		let l:segmentated_string[l:cursor_position] = '^'

		let l:iter = 0
		let l:iterations = len(l:segmentated_string)

		let l:ent_pnt_index = 0
		let l:cursor_point = -1 

		let l:entry_points = []


		while l:iter < l:iterations
			if (l:segmentated_string[l:iter] == l:seek_char) || (l:segmentated_string[l:iter] == 'D')
				let l:entry_points = add(l:entry_points, l:ent_pnt_index)
				let l:ent_pnt_index = l:ent_pnt_index + 1
			else
				if l:segmentated_string[l:iter] == '^'
					let l:cursor_point = l:ent_pnt_index
					let l:entry_points = add(l:entry_points, l:ent_pnt_index)
					let l:ent_pnt_index = l:ent_pnt_index + 1
				endif
			endif
			let l:iter = l:iter + 1
		endwhile



		let l:iterations = len(l:segmentated_string)
		let l:iter = 0
		let l:iter_2 = 0
		let l:skip_1 = 0
		let l:skip_2 = 0

		while l:iter < l:iterations
			if (l:segmentated_string[l:iter] == l:seek_char) || (l:segmentated_string[l:iter] == 'D') || (l:segmentated_string[l:iter] == '^')
				if (l:iter_2 % 2 != 0)
					let l:skip_1 = s:Get_number_of_digits_in_a_number(abs(l:entry_points[l:iter_2] - l:cursor_point))-1
					let l:result_1 = l:result_1 .. string(abs(l:entry_points[l:iter_2] - l:cursor_point))
					let l:result_2 = l:result_2 .. ' '
				else
					let l:skip_2 = s:Get_number_of_digits_in_a_number(abs(l:entry_points[l:iter_2] - l:cursor_point))-1
					let l:result_2 = l:result_2 .. string(abs(l:entry_points[l:iter_2] - l:cursor_point))
					let l:result_1 = l:result_1 .. ' '
				endif
				let l:iter_2 = l:iter_2 + 1
			else
				if l:skip_2 == 0
					if l:segmentated_string[l:iter] == '	'
						let l:result_2 = l:result_2 .. '	'
					else
						let l:result_2 = l:result_2 .. ' '
					endif
				else
					let l:skip_2 = l:skip_2 - 1
				endif

				if l:skip_1 == 0
					if l:segmentated_string[l:iter] == '	'
						let l:result_1 = l:result_1 .. '	'
					else
						let l:result_1 = l:result_1 .. ' '
					endif
				else
					let l:skip_1 = l:skip_1 - 1
				endif
			endif
			let l:iter = l:iter + 1
		endwhile

	endif
	
	if (strchars(l:result_1) != 0)

		let l:iterations = strdisplaywidth(getline(s:line_num_1+1))
		let l:iter = strdisplaywidth(l:result_1)

		while l:iter < l:iterations 
			let l:result_1 = l:result_1 .. ' '
			let l:iter = l:iter + 1
		endwhile

		let l:iterations = strdisplaywidth(getline(s:line_num_2+1))
		let l:iter = strdisplaywidth(l:result_2)

		while l:iter < l:iterations
			let l:result_2 = l:result_2 .. ' '
			let l:iter = l:iter + 1
		endwhile

	endif

	let l:result = [l:result_1, l:result_2]

	return l:result
endfunction

function cheat_line#Update_cheat_line()

		let s:line_num_1 = nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L1_relative_pos']
		let s:line_num_2 =nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L2_relative_pos']
		let l:clmn_num = nvim_win_get_cursor(0)[1]

		call nvim_buf_del_extmark(0, s:mark_ns, s:mark_id_1)
		call nvim_buf_del_extmark(0, s:mark_ns, s:mark_id_2)

		if s:line_num_1 < 0
			let s:line_num_1 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L1_pos_if_too_high']
		else
			if s:line_num_1 >= line('$')
				let s:line_num_1 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L1_pos_if_too_low']
			endif
		endif

		if s:line_num_2 < 0
			let s:line_num_2 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L2_pos_if_too_high']
		else
			if s:line_num_2 >= line('$')
				let s:line_num_2 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L2_pos_if_too_low']
			endif
		endif

		let l:res = s:Generate_cheat_lines (nvim_win_get_cursor(0)[0])
		let s:string_1 = l:res[0]
		let s:string_2 = l:res[1]

		let s:mark_id_1 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_1,
					\ 0,
					\ { 
					\	'virt_text' : [[s:string_1, g:cheat_line_config['L1_highlight_group']]],
					\	'virt_text_pos' : 'overlay',
					\ },
					\)

		let s:mark_id_2 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_2,
					\ 0,
					\ { 
					\	'virt_text' : [[s:string_2, g:cheat_line_config['L2_highlight_group']]],
					\	'virt_text_pos' : 'overlay',
					\ },
					\)

endfunction

function cheat_line#Toggle_cheat_line()
	if (s:cheat_line_enabled == 0)

		augroup Cheatline
			autocmd!
			autocmd CursorMoved * call cheat_line#Update_cheat_line()
			autocmd CursorMovedI * call cheat_line#Update_cheat_line()
		augroup END

		let s:line_num_1 = nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L1_relative_pos']
		let s:line_num_2 =nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L2_relative_pos']

		let l:clmn_num = nvim_win_get_cursor(0)[1]

		if s:line_num_1 < 0
			let s:line_num_1 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L1_pos_if_too_high']
		else
			if s:line_num_1 >= line('$')
				let s:line_num_1 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L1_pos_if_too_low']
			endif
		endif

		if s:line_num_2 < 0
			let s:line_num_2 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L2_pos_if_too_high']
		else
			if s:line_num_2 >= line('$')
				let s:line_num_2 = nvim_win_get_cursor(0)[0] - 1 + g:cheat_line_config['L2_pos_if_too_low']
			endif
		endif

		let l:res = s:Generate_cheat_lines (nvim_win_get_cursor(0)[0])
		let s:string_1 = l:res[0]
		let s:string_2 = l:res[1]

		"'virt_text_win_col' : l:clmn_num,
		let s:mark_id_1 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_1,
					\ 0,
					\ { 
					\	'virt_text' : [[s:string_1, g:cheat_line_config['L1_highlight_group']]],
					\	'virt_text_pos' : 'overlay',
					\ },
					\)

		let s:mark_id_2 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_2,
					\ 0,
					\ { 
					\	'virt_text' : [[s:string_2, g:cheat_line_config['L2_highlight_group']]],
					\	'virt_text_pos' : 'overlay',
					\ },
					\)

		let s:cheat_line_enabled = 1
		let g:cheat_line_enabled = 1
	else
		augroup Cheatline
			autocmd!
		augroup END

		call nvim_buf_del_extmark(0, s:mark_ns, s:mark_id_1)
		call nvim_buf_del_extmark(0, s:mark_ns, s:mark_id_2)
		let s:cheat_line_enabled = 0
		let g:cheat_line_enabled = 0
	endif

endfunction

function cheat_line#Change_pointing_mode()
	if g:cheat_line_config['point_to_first_char'] == 0
		let g:cheat_line_config['point_to_first_char'] = 1
	else
		let g:cheat_line_config['point_to_first_char'] = 0
	endif
	if (s:cheat_line_enabled == 1)
		call cheat_line#Update_cheat_line()
	endif
endfunction
