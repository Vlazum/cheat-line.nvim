let g:cheat_line_config = {
\							'point_to_first_char' : 1,
\							'L1_highlight_group' : ['ErrorMsg', 'Constant'],
\							'L2_highlight_group' : ['ErrorMsg', 'Constant'],
\						    'L1_relative_pos' : -1,
\						    'L2_relative_pos' : -2,	
\						    'L1_pos_if_too_high' : 2,	
\						    'L2_pos_if_too_high' : 1,	
\						    'L1_pos_if_too_low' : -1,	
\						    'L2_pos_if_too_low' : -2,	
\						  }

let g:cheat_line_enabled = 0 
let s:cheat_line_enabled = 0 

let s:mark_ns = nvim_create_namespace('cheat_line')

" marks for virtual text entities
let s:mark_id_1 = 0
let s:mark_id_2 = 0

" Refines the given word marking the beginnig and end of each element
" replacing everything else with whitespaces.
" i.e.
" 
" in:	This_is_a_word
" out:	B            E
"
function Refine_word (word)
	if strchars(a:word) == 1
		return 'D'
	endif

	let l:result = 'B'

	let l:iter = 0
	let l:iterations = strchars(a:word)
	while l:iter < (l:iterations-2)
		let l:result = l:result .. ' '
		let l:iter = l:iter + 1
	endwhile

	let l:result = l:result .. 'E'

	return l:result
endfunction


" Refines the given divider marking the beginnig and end of each element
" replacing everything else with whitespaces.
" i.e.
" 
" in:	(.. &example* )
" out:	B E B       E D
"
function Refine_divider (divider)
	let l:result = ""
	let l:whitespaces = split(a:divider, '\S\+')
	let l:non_whitespaces = split(a:divider, '\s\+')

	if len(l:whitespaces) == 0
		return Refine_word(l:non_whitespaces[0])
	endif

	if len(l:non_whitespaces) == 0
		return a:divider
	endif

	let l:first_char_whitespace = -1
	if (l:whitespaces[0][0] == a:divider[0])
		let l:first_char_whitespace = 1
	else
		let l:first_char_whitespace = 0
	endif

	let l:iter = 0
	let l:iterations = len(l:whitespaces) + len(l:non_whitespaces)
	let l:whitespace_iter = 0
	let l:non_whitespace_iter = 0
	while l:iter < l:iterations
		if (l:iter % 2) != l:first_char_whitespace
			let l:result = l:result .. l:whitespaces[l:whitespace_iter]
			let l:whitespace_iter = l:whitespace_iter + 1
		else
			let l:result = l:result .. Refine_word(l:non_whitespaces[l:non_whitespace_iter])
			let l:non_whitespace_iter = l:non_whitespace_iter + 1
		endif

		let l:iter = l:iter + 1
	endwhile

	return l:result
endfunction


" Extends the line for it to be the same length as the current buffer
function Stretch_to_the_buffer (input)

	let l:result = a:input
	let l:iter = strdisplaywidth(l:result)
	while l:iter < winwidth(0)
		let l:result = l:result .. ' '
		let l:iter = l:iter + 1
	endwhile

	return l:result
endfunction
	

" Processes cursor line marking the beginning and the end of each word
" replacing everything else with whitespaces. B for beginning, E for end, D
" for both
" i.e.
"
" in:	This is the ("test") line.
" out:	B  E BE B E BEB  EBE B  ED
"
function Process_line (input_line)

	let l:words = split(a:input_line, '\W\+')
	let l:dividers = split(a:input_line, '\w\+')

	" cover the edgecases
	if strchars(a:input_line) == 0
		return Stretch_to_the_buffer("")
	endif
	if len(l:words) == 0
		return Stretch_to_the_buffer(Refine_divider(l:dividers[0]))
	endif
	if len(l:dividers) == 0
		return Stretch_to_the_buffer(Refine_word(l:words[0]))
	endif

	let l:first_char_word = -1
	if (l:words[0][0] == a:input_line[0])
		let l:first_char_word = 1
	else
		let l:first_char_word = 0
	endif

	let l:result = ""

	let l:iter = 0
	let l:iterations = len(l:words) + len(l:dividers)
	let l:word_iter = 0
	let l:divider_iter = 0
	while l:iter < l:iterations
		if (l:iter % 2) != l:first_char_word
			let l:result = l:result .. Refine_word(l:words[l:word_iter]) 
			let l:word_iter = l:word_iter + 1
		else
			let l:result = l:result .. Refine_divider(l:dividers[l:divider_iter]) 
			let l:divider_iter = l:divider_iter + 1
		endif

		let l:iter = l:iter + 1
	endwhile

	return Stretch_to_the_buffer(l:result)
endfunction


" Inserts a character into a string
function Insert_char_to_string (input_line, insertion_line, position)
	let l:result = ""
	let l:iter = 0

	while l:iter < a:position+1
		let l:result = l:result .. a:input_line[l:iter]
		let l:iter = l:iter + 1
	endwhile

	let l:result = l:result .. a:insertion_line
	let l:iter = a:position+1

	while l:iter < strchars(a:input_line)
		let l:result = l:result .. a:input_line[l:iter]
		let l:iter = l:iter + 1
	endwhile

	return l:result
endfunction

" Replaces a character in a string
function Replace_char_in_string (input_line, insertion_char, position)
	let l:result = ""
	let l:iter = 0

	while l:iter < a:position
		let l:result = l:result .. a:input_line[l:iter]
		let l:iter = l:iter + 1
	endwhile

	let l:result = l:result .. a:insertion_char
	let l:iter = a:position+1

	while l:iter < strchars(a:input_line)
		let l:result = l:result .. a:input_line[l:iter]
		let l:iter = l:iter + 1
	endwhile

	return l:result
endfunction


" Generates virtual text for cheat lines 
function Generate_cheatlines ()
	let l:processed_line = Process_line(getline('.')) " process the cursorline
	let l:cursor_position = nvim_win_get_cursor(0)[1]

	let l:seek_char = 'N'
	if g:cheat_line_config['point_to_first_char'] == 1
		let l:seek_char = 'B'
	else
		let l:seek_char = 'E'
	endif

	if l:processed_line[l:cursor_position] == '	'
		let l:processed_line = Replace_char_in_string(l:processed_line, 'D', l:cursor_position)
		let l:iter = 0
		while l:iter < &tabstop-1
			let l:processed_line = Insert_char_to_string(l:processed_line, ' ', l:cursor_position-1)
			let l:iter = l:iter + 1
		endwhile
	else
		let l:processed_line = Replace_char_in_string(l:processed_line, 'D', l:cursor_position)
	endif

	
	let l:iter = 0
	let l:char_count = 0
	let l:iterations = nvim_win_get_cursor(0)[1]

	while l:iter < l:iterations
		if (l:processed_line[l:iter] == l:seek_char) || (l:processed_line[l:iter] == 'D')
			let l:char_count = l:char_count + 1
		endif
		let l:iter = l:iter + 1
	endwhile
	let l:cursor_relative_pos = l:char_count


	let l:line_1 = [["", ""]]
	let l:line_2 = [["", ""]]
	let l:line_1_hl_group = 0
	let l:line_2_hl_group = 0

	let l:skip_char = 0
	let l:char_count = 0
	let l:iterations = strchars(l:processed_line)
	let l:iter = 0

	while l:iter < l:iterations

		if (l:processed_line[l:iter] == l:seek_char) || (l:processed_line[l:iter] == 'D')
			let l:mark_num = abs(l:char_count - l:cursor_relative_pos) % 100 
			let l:char_count = l:char_count + 1

			if l:char_count % 2 == 0

				if l:mark_num > 9
					let l:skip_char = 1
				endif

				let l:line_1[len(l:line_1)-1][0] = l:line_1[len(l:line_1)-1][0] .. string(l:mark_num)

				let l:line_1[len(l:line_1)-1][1] = g:cheat_line_config['L1_highlight_group'][l:line_1_hl_group]
				let l:line_1_hl_group = (l:line_1_hl_group + 1) % 2

				let l:line_1 = add(l:line_1, ["", ""])

			else
				if l:skip_char == 0
					let l:line_1[len(l:line_1)-1][0] = l:line_1[len(l:line_1)-1][0] .. ' '
				else
					let l:skip_char = 0
				endif
			endif

		else

			if l:processed_line[l:iter] == '	'
				let l:line_1[len(l:line_1)-1][0] = l:line_1[len(l:line_1)-1][0] .. '	'
			else
				if l:skip_char == 0
					let l:line_1[len(l:line_1)-1][0] = l:line_1[len(l:line_1)-1][0] .. ' '
				endif
			endif
			let l:skip_char = 0

		endif

		let l:iter = l:iter + 1
	endwhile


	let l:skip_char = 0
	let l:char_count = 0
	let l:iterations = strchars(l:processed_line)
	let l:iter = 0

	while l:iter < l:iterations

		if (l:processed_line[l:iter] == l:seek_char) || (l:processed_line[l:iter] == 'D')
			let l:mark_num = abs(l:char_count - l:cursor_relative_pos) % 100 
			let l:char_count = l:char_count + 1

			if l:char_count % 2 != 0

				if l:mark_num > 9
					let l:skip_char = 1
				endif

				let l:line_2[len(l:line_2)-1][0] = l:line_2[len(l:line_2)-1][0] .. string(l:mark_num)

				let l:line_2[len(l:line_2)-1][1] = g:cheat_line_config['L1_highlight_group'][l:line_2_hl_group]
				let l:line_2_hl_group = (l:line_2_hl_group + 1) % 2

				let l:line_2 = add(l:line_2, ["", ""])
			else
				if l:skip_char == 0
					let l:line_2[len(l:line_2)-1][0] = l:line_2[len(l:line_2)-1][0] .. ' '
				else
					let l:skip_char = 0
				endif
			endif

		else

			if l:processed_line[l:iter] == '	'
				let l:line_2[len(l:line_2)-1][0] = l:line_2[len(l:line_2)-1][0] .. '	'
			else
				if l:skip_char == 0
					let l:line_2[len(l:line_2)-1][0] = l:line_2[len(l:line_2)-1][0] .. ' '
				endif
			endif
			let l:skip_char = 0

		endif

		let l:iter = l:iter + 1
	endwhile

	return [l:line_1, l:line_2]
endfunction


" Recalculates cheat line on update
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

		let l:virt_text_list = Generate_cheatlines()
		let l:virt_text_1 = l:virt_text_list[0]
		let l:virt_text_2 = l:virt_text_list[1]

		let s:mark_id_1 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_1,
					\ 0,
					\ { 
					\	'virt_text' : l:virt_text_1,
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
					\	'virt_text' : l:virt_text_2,
					\	'virt_text_pos' : 'overlay',
					\ },
					\)

endfunction


" Toggles the display of the cheat_line
" i.e. 
"
"
"       3      1 1      3    
"  4       2    0    2      4
"  This is the ("test") line.
"
" Cheat line consists of two lines pointing to the beginning or ending of
" every word on the line. For clarity on every line each number is 
" highlighted using one of two highlight groups
" 
function cheat_line#Toggle()
	if (s:cheat_line_enabled == 0)

		augroup Cheatline
			autocmd!
			autocmd CursorMoved * call cheat_line#Update_cheat_line()
			autocmd CursorMovedI * call cheat_line#Update_cheat_line()
		augroup END

		let s:line_num_1 = nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L1_relative_pos']
		let s:line_num_2 = nvim_win_get_cursor(0)[0]-1 + g:cheat_line_config['L2_relative_pos']

		" catch the edge cases
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

		let l:virt_text_list = Generate_cheatlines()
		let l:virt_text_1 = l:virt_text_list[0]
		let l:virt_text_2 = l:virt_text_list[1]

		let s:mark_id_1 = nvim_buf_set_extmark
					\(
					\ 0,
					\ s:mark_ns,
					\ s:line_num_1,
					\ 0,
					\ { 
					\	'virt_text' : l:virt_text_1,
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
					\	'virt_text' : l:virt_text_2,
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

" Updates entries in g:cheat_line_setup according to input_config
" takes key : value pairs 
" i.e. 
"	call cheat_line#Setup ('L1_relative_pos' : -1, 'L2_relative_pos' : -2)
"	will change respective values in g:cheat_line_config dictionary
"
"	call cheat_line#Setup ('cheat line higlight' : 'red', 'L2_relative_pos' : -2)
"	will only change 'L2_relative_pos' entry since entry 'cheat line higlight'
"	is not present in g:cheat_line_config dictionary
function cheat_line#Setup (input_config)
	for key in keys(g:cheat_line_config)
		if has_key(a:input_config, key)
			let g:cheat_line_config[key] = a:input_config[key]
		endif
	endfor
endfunction

function cheat_line#Change_pointing_mode()
	if g:cheat_line_config['point_to_first_char'] == 0
		let g:cheat_line_config['point_to_first_char'] = 1
	else
		let g:cheat_line_config['point_to_first_char'] = 0
	endif

	call cheat_line#Update_cheat_line()
endfunc
