local v = vim
local vscode = require('vscode')

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
  [[<Cmd>lua require('vscode').action('editor.action.inlineSuggest.hide')<CR><esc>]]
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

-- VS Code "Go to Definition" (same as Ctrl + Click)
normalMap(
  '<leader>i',
  "<Cmd>lua require('vscode').action('editor.action.revealDefinition')<CR>"
)
normalMap(
  '<leader>]',
  "<Cmd>lua require('vscode').action('editor.action.revealDefinition')<CR>"
)

-- close current editor file
normalMap('<leader>d', [[<Cmd>lua require('vscode').action('workbench.action.closeActiveEditor')<CR>]])

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

-- Swap ' and ` to "default" to column level precision over only line precision. For
-- example, 'a will now go to the exact position of the mark in a, while `a only
-- goes to the beginning of that line. '' can also be quite useful while editing a line.
v.keymap.set({ "n", "x", "o" }, "'", "`")
v.keymap.set({ "n", "x", "o" }, "`", "'")

-- show/focus the file explorer side panel
normalMap(
  '<leader><leader>t',
  [[<Cmd>lua require('vscode').action('workbench.view.explorer')<CR>]]
)

-- show/focus terminal
normalMap('<leader><leader><leader>t', [[<Cmd>lua require('vscode').action('terminal.focus')<CR>]])
normalMap('<leader>f', [[<Cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>]])

-- Only when running inside VS Code
normalMap(
  "%",
  function()
    vscode.action('editor.action.jumpToBracket')
  end
)

-- use VSCode search and replace
normalMap('<leader>/', [[<Cmd>lua require('vscode').action('workbench.action.findInFiles')<CR>]])

-- create new line below current line without leaving normal mode or moving cursor
normalMap('-', 'm`o<esc>``')

-- create new line above current line without leaving normal mode or moving cursor
normalMap('_', 'm`O<esc>``')

-- MRU list. J and K will go up and down list. G and GG also work from there
normalMap('<leader>;',
  [[<Cmd>lua require('vscode').action('workbench.action.quickOpenPreviousRecentlyUsedEditor')<CR>]])

-- auto format current line
normalMap('==', [[<Cmd>lua require('vscode').action('editor.action.formatSelection')<CR>]])

-- auto format selected lines in visual mode
visualOnlyMap('=', [[<Cmd>lua require('vscode').call('editor.action.formatSelection')<CR><Esc>]])

-- Enter Insert mode, move VS Code's cursor to the end of the line, then have
-- VS Code type the newline so its indentation rules are used.
normalMap(
  'o',
  function()
    vscode.with_insert(function()
      vscode.call('cursorLineEnd')
      vscode.call('default:type', { args = { text = '\n' } })
    end)
  end
)

-- To open above, move VS Code's cursor to the preceding line's end before
-- typing the newline. There is no preceding line when already on the first.
normalMap(
  'O',
  function()
    local isFirstLine = v.fn.line('.') == 1

    vscode.with_insert(function()
      if isFirstLine then
        vscode.call('editor.action.insertLineBefore')
        return
      end

      vscode.call('cursorMove', { args = { to = 'up', by = 'line' } })
      vscode.call('cursorLineEnd')
      vscode.call('default:type', { args = { text = '\n' } })
    end)
  end
)

normalMap(
  '<leader><CR>',
  function()
    v.cmd('normal! i' .. v.keycode('<CR><Esc>'))

    local currentLine = v.fn.line('.') - 1 -- VS Code lines are zero-based
    vscode.call(
      'editor.action.formatSelection',
      {
        range = { currentLine, currentLine },
      }
    )

    v.cmd('normal! ^')
  end
)

-- save
normalMap('<leader>s', [[<Cmd>lua require('vscode').action('workbench.action.files.save')<CR>]])

-- add a space
normalMap('<leader>z', 'i <esc>')

-- run test-file task
normalMap('<leader>r', [[<Cmd>lua require('vscode').action('workbench.action.tasks.runTask')<CR>]])

normalMap(
  '<leader><leader>l',
  function()
    vscode.action('workbench.action.tasks.runTask', { args = { 'lint' } })
  end
)

normalMap(
  '<leader><leader>a',
  function()
    vscode.action('workbench.action.tasks.runTask', { args = { 'all' } })
  end
)

-- "<Cmd>lua require('vscode').action('editor.action.rename')<CR>"
normalMap(
  '<leader>j',
  function()
    vscode.action('editor.action.rename')
  end
)
normalMap(
  '<leader>k',
  "<Cmd>lua require('vscode').action('editor.action.quickFix')<CR>"
)

normalMap(
  '<leader>t',
  "^h/function <CR>wve\"ly$h/{<CR>%o<CR>private static function tst<ESC>\"lpbftl~hea(): void {<CR>}<ESC>k$b"
)
-- modify/toggle mapping. For now used to toggle todo box (used by VSCode Todo+ extension). In the future, will be used
-- to toggle other things in code files, such as toggling a method from between `private` and `public`
-- normalMap('<leader>j', function() toggleTodoBox(false) end)
-- normalMap('<leader>k', function() toggleTodoBox(true) end)

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
normalMap('<leader>g', [[<Cmd>lua require('vscode').action('workbench.view.scm')<CR>]])

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
