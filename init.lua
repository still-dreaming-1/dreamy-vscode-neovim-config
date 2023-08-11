local v = vim
v.g.mapleader = ' '

-- make searching easier
v.o.ignorecase = true
v.o.smartcase = true
v.o.timeout = false
v.o.clipboard = 'unnamedplus' -- yank and paste to/from clipboard

function normalMap(left, right)
   v.keymap.set('n', left, right)
end

function insertMap(left, right)
   v.keymap.set('i', left, right)
end

function visualAndSelectMap(left, right)
   v.keymap.set('v', left, right)
end

function visualOnlyMap(left, right)
   v.keymap.set('x', left, right)
end

function selectOnlyMap(left, right)
   v.keymap.set('s', left, right)
end

insertMap(
   '<esc>',
   [[<Cmd>call VSCodeNotify('editor.action.inlineSuggest.hide')<CR><esc>]]
)

-- don't need control key to get into blockwise visual mode
normalMap('<leader>v', '<C-v>')

normalMap( -- use VSCode search and replace feature with word under cursor
   '<leader>*',
   "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>') })<CR>"
)
-- VS Code "Go to Definition" (same as Ctrl + Click)
normalMap('<leader>]', [[<Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>]])

-- close current editor file
normalMap('<leader>d', [[<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>]])

-- go to smart start of line
v.keymap.set(
   {'n', 'x'}, -- normal and visual (only) mode
   '<leader>h',
   '^'
)

v.keymap.set( -- go to end of line
   {'n', 'o'},
   '<leader>l',
   '$'
)

visualOnlyMap( -- go to end of line
   '<leader>l',
   '$h' -- the "h" prevents it from selecting the newline character
)

-- show/focus the file explorer side panel
normalMap(
   '<leader>t',
   [[<Cmd>call VSCodeNotify('workbench.view.explorer')<CR>]]
)

-- show/focus terminal
normalMap('<leader><leader>t', [[<Cmd>call VSCodeNotify('terminal.focus')<CR>]])
--
-- show/focus terminal
normalMap('<leader>f', [[<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>]])

-- use VSCode search and replace
normalMap('<leader>/', [[<Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>]])

-- create new line below current line without leaving normal mode or moving cursor
normalMap('-', 'm`o<esc>``')

-- create new line above current line without leaving normal mode or moving cursor
normalMap('_', 'm`O<esc>``')

-- MRU list. J and K will go up and down list. G and GG also work from there
normalMap('<leader>;', [[<Cmd>call VSCodeNotify('workbench.action.quickOpenPreviousRecentlyUsedEditor')<CR>]])

-- auto indent current line
normalMap('==', [[<Cmd>call VSCodeNotify('editor.action.reindentselectedlines')<CR>]])

-- auto indent selected lines in visual mode
visualOnlyMap('=', [[<Cmd>call VSCodeNotifyVisual('editor.action.reindentselectedlines', 0)<CR>]])

-- change o to also use VS Code to auto indent
--normalMap('o', "o<Cmd>call VSCodeNotify('editor.action.reindentselectedlines')<CR>")
--vim.keymap.set('n', 'o', "o<Cmd>call VSCodeNotify('editor.action.reindentselectedlines')<CR>")

--
-- change O to also use VS Code to auto indent
normalMap('O', "O<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")

normalMap(
   '<leader><CR>',
   'i<CR><Esc><Cmd>call VSCodeCallRange("editor.action.reindentselectedlines", line("."), line("."), 0)<CR><Esc>^'
)

-- save
normalMap('<leader>s', [[<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>]])

-- add a space
normalMap('<leader>z', 'i <esc>')

-- run test-file task
normalMap('<leader>r', [[<Cmd>call VSCodeNotify('workbench.action.tasks.runTask', 'test-file')<CR>]])
-- run test task
normalMap('<leader><leader>r', [[<Cmd>call VSCodeNotify('workbench.action.tasks.runTask', 'test')<CR>]])

normalMap('<leader><leader>l', [[<Cmd>call VSCodeNotify('workbench.action.tasks.runTask', 'lint')<CR>]])

normalMap('<leader><leader>a', [[<Cmd>call VSCodeNotify('workbench.action.tasks.runTask', 'all')<CR>]])

-- oppen TODO file (for Todo+ VSCode extension)
normalMap('<leader>i', [[<Cmd>call VSCodeNotify('todo.open')<CR>]])

function toggleTodoBox(reverse)
   local line = v.api.nvim_get_current_line()
   local firstNonWhitespaceIndex = string.find(line, "%S")
   if firstNonWhitespaceIndex == nil then
      if reverse then
         v.cmd([[call VSCodeNotify('todo.toggleDone')]]) -- changes to checked box
      else
         v.cmd([[call VSCodeNotify('todo.toggleBox')]]) -- changes to an unchecked box
      end
      return
   end
   -- Get up to 3 bytes starting from the first non-whitespace character because both "☐" and "✔" are 3 bytes
   local firstNonWhitespaceChar = string.sub(line, firstNonWhitespaceIndex, firstNonWhitespaceIndex + 2)
   if firstNonWhitespaceChar == '☐' then
      if reverse then
         v.cmd([[call VSCodeNotify('todo.toggleBox')]]) -- changes to no box
      else
         v.cmd([[call VSCodeNotify('todo.toggleDone')]]) -- changes to checked box
      end
   elseif firstNonWhitespaceChar == '✔' then
      if reverse then
         v.cmd([[call VSCodeNotify('todo.toggleDone')]]) -- changes to unchecked box
      else
         -- this first one has to be blocking, so it finishes before the next one starts:
         v.cmd([[call VSCodeCall('todo.toggleBox')]]) -- changes to an unchecked box (blocking call)

         v.cmd([[call VSCodeNotify('todo.toggleBox')]]) -- changes to no box
      end
   else -- no box
      if reverse then
         v.cmd([[call VSCodeNotify('todo.toggleDone')]]) -- changes to checked box
      else
         v.cmd([[call VSCodeNotify('todo.toggleBox')]]) -- changes to unchecked box
      end
   end
end

-- modify/toggle mapping. For now used to toggle todo box (used by VSCode Todo+ extension). In the future, will be used
-- to toggle other things in code files, such as toggling a method from between `private` and `public`
normalMap('<leader>j', function() toggleTodoBox(false) end)
normalMap('<leader>k', function() toggleTodoBox(true) end)

--[===[
-- lua alternative to ":" (enter lua code instead of vimscript)
normalMap('<leader>i', ':lua ')

-- pasting in visual mode will yank what you just pasted so it does overwritten by what was pasted over(breaks specifying register, but I don't use them)
visualOnlyMap('p', 'pgvygv<esc>')
-- use to unhighlight/unsearch the last search term. You can hit n to re-search/highlight the search term
--v.keymap.set(
--    'n',
--    '<leader>u',
--    '<Cmd>noh<Bar>:echo<CR>',
--    {
--        silent = true,
--    }
--)

-- show/focus source control/git view
normalMap('<leader>g', [[<Cmd>call VSCodeNotify('workbench.view.scm')<CR>]])

-- move after the next dot character (this should be turned into a custom motion where instead of . you can type
-- anything you want to move after. This would be the opposite of t
normalMap('<leader>a.', 'f.l<esc>')

-- make . work with visually selected lines
visualOnlyMap('.', ':norm.<CR>')

-- make down not ignore wrapping lines
normalMap('j', 'gj')

-- make up not ignore wrapping lines
normalMap('k', 'gk')

-- <leader>. will now repeat the last command. Similar to using . to repeat
normalMap('<leader>.', '@:')

-- make backspace delete everything before the cursor until only white space
normalMap('<bs>', 'hv^d')

-- use ( to move line up
normalMap('(', 'ddkP')

-- use ) to move line down
normalMap(')', 'ddp')

-- go one screen down
normalMap('<leader>j', 'Lzt')

-- go one screen up
normalMap('<leader>k', 'Hzb')

-- surround visual selection with double quotes
visualOnlyMap('<leader>"', [[<esc>`>a"<esc>`<i"<esc>]])

-- surround visual selection with single quotes
visualOnlyMap(
   "<leader>'",
   [[<esc>`>a'<esc>`<i'<esc>]]
)

-- surround visual selection with backticks
visualOnlyMap(
   '<leader>`',
   [[<esc>`>a`<esc>`<i`<esc>]]
)


-- surround visual selection with curly braces
visualOnlyMap(
   '<leader>{',
   [[<esc>`>a}<esc>`<i{<esc>]]
)]===]
