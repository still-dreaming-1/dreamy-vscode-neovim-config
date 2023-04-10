# dreamy-vscode-neovim-config

This contains my nvim config files for use with vscdoe-neovim. I started having difficulties with Neovim plugins and dependencies partially applying to both Neovim and VSCode Neovim even when only one config or the other was trying to use them. So now I have 3 repos for this kind of thing. One is all my other dotfiles. The other is for systems that will only use Neovim through VSCode, and the other is for systems that will only use Neovim without VSCode.

I don't recommend anyone try to install and use this config as is, it is probably more useful as inspiration for your own, or if you just want to see my config.

The contents of this folder end up in my WSL2 files at `/home/username/.config/nvim/`. I have VSCode Neovim configured to use my Neovim installation from WSL2. When I use VSCode's remote features to edit files on other machines or servers, I continue to use my local Neovim installation and config from my local WSL2. It is not recommended to try to install and run the VSCode Neovim extensions on a remote machine or to try to get it to use a remote instance of Neovim (other than the "remote" instance on your local WSL/WSL2).
