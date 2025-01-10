# cheat-line.nvim

Cheat line is a very simple vimscript based neovim plugin that helps with navigating within the currently 
selected line. Cheat line consists of two separate strings located above the cursor line by default. They 
point to the beginning of each word within that line with numbers representing their position relative to 
the cursor. Each line uses two highlight groups for number marks for better clarity.

![image](https://github.com/user-attachments/assets/7d890386-8d7d-40bf-b50e-fa1a5917c5b8)

## Usage
To toggle cheat line use `ToggleCheatLine()` custom command. Type number above the beginning of the word 
you would like to navigate to then press `w` or `b` depending on weather the word is in front or behind 
the cursor. 

If you'd prefer for the cheat line to point to the end of the word use `ChangePointingMode()` command and 
use `e` and `ge` instead of `w` and `b`

## Commands

`ToggleCheatLine`      - toggles the cheat line

`ChangePointingMode`   - flips the value of `points_to_first_char` entry in g:cheat_line_config

`UpdateCheatLine`      - updates the cheat line

## Setup
Cheat line can function properly without setup however some properties can be adjusted.
For changing properties use `cheat_line#setup()` function. The function takes dictionary of properties you would like to change and values that you would like to assign to them. For example: `call cheat_line#setup({'L1_highlight_group' : ['SpecialKey, Ignore'], 'L2_highlight_group' : ['SpecialKey, Ignore']})`

If the entry specified in the dictionary provided to the `cheat_line#setup()` function does not exist in g:cheat_line_config it gets ignored 

### adjustable properties:

| Property name          | Description                                                                                                     | Default value |        
| ---------------------- | --------------------------------------------------------------------------------------------------------------- | ------------- |
| `points_to_first_char` | if set to 1 points to the first character in each word of a cursor line. Points to the last character otherwise | 1             |
| `L1_highlight_group`   | defines the highlight groups for first string of cheat line                                                     | ['ErrorMsg', 'Constant']      |
| `L2_highlight_group`   | defines the highlight groups for second string of cheat line                                                    | ['ErrorMsg', 'Constant']      |
| `L1_relative_pos`      | defines position of the first line relative to the cursor line                                                  | -1            |
| `L2_relative_pos`      | defines position of the second line relative to the cursor line                                                 | -2            |
| `L1_pos_if_too_high`    | defines position of the first line if it has gone above the line 0                                             | 2             |
| `L2_pos_if_too_high`    | defines position of the second line if it has gone above the line 0                                            | 1             |        
| `L1_pos_if_too_low`     | defines position of the first line if it has gone below the last line in the file                              | -1            |
| `L2_pos_if_too_low`     | defines position of the second line if it has gone below the last line in the file                             | -2            |
> *you can run `:so $VIMRUNTIME/syntax/hitest.vim` command to find more highlight groups*
### suggested manppings
Cheat line does not have any default mappings, however it is recommended to utilize mappings for better experience
```
nmap <silent> <leader>c :ToggleCheatLine<CR>          " for toggleing cheat line
vmap <silent> <leader>c <ESC>:ToggleCheatLine<CR>     " for toggleing cheat line in selection mode
map <leader>x :ChangePointingMode<CR>                 " for changeing pointing mode
```
