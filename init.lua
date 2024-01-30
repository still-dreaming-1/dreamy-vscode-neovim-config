local v = vim
local vscode = require('vscode-neovim')

v.g.mapleader = ' '

-- make searching easier
v.o.ignorecase = true
v.o.smartcase = true
v.o.timeout = false
v.o.clipboard = 'unnamedplus' -- yank and paste to/from clipboard

local function normalMap(left, right)
  v.keymap.set('n', left, right)
end

local function insertMap(left, right)
  v.keymap.set('i', left, right)
end

local function visualAndSelectMap(left, right)
  v.keymap.set('v', left, right)
end

local function visualOnlyMap(left, right)
  v.keymap.set('x', left, right)
end

local function selectOnlyMap(left, right)
  v.keymap.set('s', left, right)
end

-- prevents register from getting overwritten/changed when you visually select some text and then p over it
visualOnlyMap('p', 'P')

insertMap(
  '<esc>',
  [[<Cmd>call VSCodeNotify('editor.action.inlineSuggest.hide')<CR><esc>]]
)

-- don't need control key to get into blockwise visual mode
normalMap('<leader>v', '<C-v>')

normalMap( -- use VSCode search and replace feature with word under cursor
  '<leader>*',
  function()
    vscode.action(
      'workbench.action.findInFiles',
      { args = { query = v.fn.expand('<cword>') } }
    )
  end
)

normalMap( -- VS Code "Go to Definition" (same as Ctrl + Click)
  '<leader>]',
  "<Cmd>lua require('vscode-neovim').action('editor.action.revealDefinition')<CR>"
)

-- close current editor file
normalMap('<leader>d', [[<Cmd>lua require('vscode-neovim').action('workbench.action.closeActiveEditor')<CR>]])

-- go to smart start of line
v.keymap.set(
  { 'n', 'x' }, -- normal and visual (only) mode
  '<leader>h',
  '^'
)

v.keymap.set( -- go to end of line
  { 'n', 'o' },
  '<leader>l',
  '$'
)

visualOnlyMap( -- go to end of line
  '<leader>l',
  '$h'         -- the "h" prevents it from selecting the newline character
)

-- show/focus the file explorer side panel
normalMap(
  '<leader>t',
  [[<Cmd>lua require('vscode-neovim').action('workbench.view.explorer')<CR>]]
)

-- show/focus terminal
normalMap('<leader><leader>t', [[<Cmd>lua require('vscode-neovim').action('terminal.focus')<CR>]])
--
-- show/focus terminal
normalMap('<leader>f', [[<Cmd>lua require('vscode-neovim').action('workbench.action.quickOpen')<CR>]])

-- use VSCode search and replace
normalMap('<leader>/', [[<Cmd>lua require('vscode-neovim').action('workbench.action.findInFiles')<CR>]])

-- create new line below current line without leaving normal mode or moving cursor
normalMap('-', 'm`o<esc>``')

-- create new line above current line without leaving normal mode or moving cursor
normalMap('_', 'm`O<esc>``')

-- MRU list. J and K will go up and down list. G and GG also work from there
normalMap('<leader>;',
  [[<Cmd>lua require('vscode-neovim').action('workbench.action.quickOpenPreviousRecentlyUsedEditor')<CR>]])

-- auto format current line
normalMap('==', [[<Cmd>lua require('vscode-neovim').action('editor.action.formatSelection')<CR>]])

-- auto format selected lines in visual mode
visualOnlyMap('=', [[<Cmd>lua require('vscode-neovim').call('editor.action.formatSelection')<CR><Esc>]])

-- change o to also use VS Code to auto format/indent
--normalMap('o', "A<CR><Cmd>lua require('vscode-neovim').action('editor.action.formatSelection')<CR>")
--vim.keymap.set('n', 'o', "<Cmd>lua require('vscode-neovim').action('editor.action.formatSelection')<CR>")
v.keymap.set(
  'n',
  'o',
  function()
    v.api.nvim_feedkeys('o', 'n', false)
    v.defer_fn(
      function() vscode.action('editor.action.reindentselectedlines') end,
      1
    )
  end
)


-- change O to also use VS Code to auto format/indent
--normalMap('O', "O<Cmd>lua require('vscode-neovim').action('editor.action.formatSelection')<CR>")
v.keymap.set(
  'n',
  'O',
  function()
    v.api.nvim_feedkeys('O', 'n', false)
    v.defer_fn(
      function() vscode.action('editor.action.reindentselectedlines') end,
      1
    )
  end
)

normalMap(
  '<leader><CR>',
  'i<CR><Esc><Cmd>call VSCodeCallRange("editor.action.formatSelection", line("."), line("."), 0)<CR><Esc>^'
)

-- save
normalMap('<leader>s', [[<Cmd>lua require('vscode-neovim').action('workbench.action.files.save')<CR>]])

-- add a space
normalMap('<leader>z', 'i <esc>')

-- run test-file task
normalMap('<leader>r', [[<Cmd>lua require('vscode-neovim').action('workbench.action.tasks.runTask')<CR>]])
-- run test task
normalMap('<leader><leader>r', [[<Cmd>lua require('vscode-neovim').action('workbench.action.tasks.runTask', 'test')<CR>]])

normalMap('<leader><leader>l', [[<Cmd>lua require('vscode-neovim').action('workbench.action.tasks.runTask', 'lint')<CR>]])

normalMap('<leader><leader>a', [[<Cmd>lua require('vscode-neovim').action('workbench.action.tasks.runTask', 'all')<CR>]])

-- oppen TODO file (for Todo+ VSCode extension)
normalMap('<leader>i', [[<Cmd>lua require('vscode-neovim').action('todo.open')<CR>]])

local function toggleTodoBox(reverse)
  local line = v.api.nvim_get_current_line()
  local firstNonWhitespaceIndex = string.find(line, "%S")
  if firstNonWhitespaceIndex == nil then
    if reverse then
      v.cmd([[lua require('vscode-neovim').action('todo.toggleDone')]])    -- changes to checked box
    else
      v.cmd([[lua require('vscode-neovim').action('todo.toggleBox')]])     -- changes to an unchecked box
    end
    return
  end
  -- Get up to 3 bytes starting from the first non-whitespace character because both "☐" and "✔" are 3 bytes
  local firstNonWhitespaceChar = string.sub(line, firstNonWhitespaceIndex, firstNonWhitespaceIndex + 2)
  if firstNonWhitespaceChar == '☐' then
    if reverse then
      v.cmd([[lua require('vscode-neovim').action('todo.toggleBox')]])     -- changes to no box
    else
      v.cmd([[lua require('vscode-neovim').action('todo.toggleDone')]])    -- changes to checked box
    end
  elseif firstNonWhitespaceChar == '✔' then
    if reverse then
      v.cmd([[lua require('vscode-neovim').action('todo.toggleDone')]])    -- changes to unchecked box
    else
      -- this first one has to be blocking, so it finishes before the next one starts:
      v.cmd([[lua require('vscode-neovim').call('todo.toggleBox')]])       -- changes to an unchecked box (blocking call)

      v.cmd([[lua require('vscode-neovim').action('todo.toggleBox')]])     -- changes to no box
    end
  else                                                                     -- no box
    if reverse then
      v.cmd([[lua require('vscode-neovim').action('todo.toggleDone')]])    -- changes to checked box
    else
      v.cmd([[lua require('vscode-neovim').action('todo.toggleBox')]])     -- changes to unchecked box
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
