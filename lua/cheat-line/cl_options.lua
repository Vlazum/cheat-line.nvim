local M = {}

-- word_based
-- char_based

-- cheat line setup options
M.config = {
			operation_mode				= 1, -- 1: word-based	2: char-based
			cheat_line_op_mode_default	= 1,
			cheat_line_enabled			= false,
			enable_default_mappings		= true,

			word_based = {
							line_1_relative_pos				= -1,
							line_2_relative_pos				= 1,

							line_1_pos_if_to_low			= -1,
							line_2_pos_if_to_low			= -2,

							line_1_pos_if_to_high			= 2,
							line_2_pos_if_to_high			= 1,

							line_1_hl_groups				= {'CheatLine1Primary', 'CheatLine1Secondary'},
							line_2_hl_groups				= {'CheatLine2Primary', 'CheatLine2Secondary'},

							custom_hl_group_settings		= {
																	--
																	--
																cheat_line_1_primary	= "guifg=#ffffff guibg=#00000000",
																cheat_line_1_secondary	= "guifg=#c8c8c8 guibg=#00000000",
																cheat_line_2_primary	= "guifg=#c80000 guibg=#00000000",
																cheat_line_2_secondary	= "guifg=#ff0000 guibg=#00000000"
															  },

							point_to_begining_default_val	= -1,
							index_0_on_line					= 1,
							point_to_begining				= true,
							show_index_0					= false
						 },

			char_based = {
							line_1_relative_pos				= -1,
							line_2_relative_pos				= 1,

							line_1_pos_if_to_low			= -1,
							line_2_pos_if_to_low			= -2,

							line_1_pos_if_to_high			= 2,
							line_2_pos_if_to_high			= 1,

							line_1_hl_groups				= {'CheatLine1Primary_alt', 'CheatLine1Secondary_alt'},
							line_2_hl_groups				= {'CheatLine2Primary_alt', 'CheatLine2Secondary_alt'},

							custom_hl_group_settings		= {
																cheat_line_1_primary	= "guifg=#ffffff guibg=#00000000",
																cheat_line_1_secondary	= "guifg=#c8c8c8 guibg=#00000000",
																cheat_line_2_primary	= "guifg=#ffce20 guibg=#00000000",
																cheat_line_2_secondary	= "guifg=#b99000 guibg=#00000000"
															  },

							include_less_pivot_points		= true
						 }
			}

return M
