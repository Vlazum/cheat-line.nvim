" name: 	Cheat_line.nvim
" descriptoin: 	helps you naivgate through the selected line 
" last change: 	8 June 2024
" maintainter:	Vlazm 'https://github.com/Vlazum'

if exists("g:loaded_cheat_line")
	finish
endif
let g:loaded_cheat_line = 1

command! -nargs=0 ToggleCheatLine call cheat_line#Toggle_cheat_line()
command! -nargs=0 ChangePointingMode call cheat_line#Change_pointing_mode()
command! -nargs=0 UpdateCheatLine call cheat_line#Update_cheat_line()
