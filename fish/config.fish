bind \e accept-autosuggestion

# How to setup git:
#
# cat <<EOF >> ~/.gitignore_global
# .DS_Store
# .DS_Store?
# ._*
# .Spotlight-V100
# .Trashes
# 
# *.bak
# *.swp
# *.swo
# *~
# *#
# 
# .vscode
# .idea
# .iml
# *.sublime-workspace
# EOF
#
# opam install patdiff
#
# git config --global user.email "nicolasmazzon549@gmail.com"
# git config --global user.name "Nicolas Mazzon"
# 
# git config --global core.editor "nvim"
# git config --global core.excludesfile "~/.gitignore_global"
# 
# git config --global pull.rebase true
# 
# git config --global diff.algorithm "patience"
# git config --global diff.external patdiff-git-wrapper

abbr -a objdump "objdump -M intel -C"
abbr -a cat "bat"
abbr -a hexdump "hexdump -C"
abbr -a tree "tree --gitignore"

abbr -a l "exa -T -L 2"
abbr -a ls "exa"
abbr -a ll "exa -aghHl"
abbr -a ubuntu "ssh admin@(tart ip ubuntu)"
abbr -a ninja "/Applications/'Binary Ninja.app'/Contents/MacOS/binaryninja"

if command -q tree && command -q rg
    abbr -a tree "rg --files | tree --fromfile"
end

switch (uname)
    case Darwin
        set -U fish_user_paths /opt/homebrew/bin/ $fish_user_paths
        abbr -a make "make -j$(math $(sysctl -n hw.physicalcpu) + 1)"
        abbr -a jupyter "jupyter lab --app-dir /opt/homebrew/share/jupyter/lab"

        if command -q aria2c
            abbr -a aria2c "aria2c --enable-peer-exchange=true --enable-dht=true"
        end
    case Linux
        abbr -a make "make -j$(math $(nproc) + 1)"
        abbr -a jupyter "jupyter lab"

        export TERM="xterm"
        export XCURSOR_THEME="Adwaita"
        export KITTY_ENABLE_WAYLAND="1"
        export GPG_TTY=$(tty)

        # Fix ghidra gray screen on wayland
        export _JAVA_AWT_WM_NONREPARENTING="1"

        if command -q aria2c
            abbr -a aria2c "aria2c --async-dns=false --enable-peer-exchange=true --enable-dht=true"
        end
end

fish_add_path -P ~/.local/bin
fish_add_path -P ~/.cargo/bin
fish_add_path -P ~/Projects/utils

if command -q nvim
    set EDITOR nvim
else
    set EDITOR vim
end

set PYTHON_HOST_PROG "/usr/bin/python2"
set PYTHON3_HOST_PROG "/usr/bin/python3"
set LLVM_HOME "/usr/lib/llvm/llvm"

# colored man output
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

if status --is-interactive
  if type -q modus-vivendi
    modus-vivendi
  end
end

function fish_prompt
  set_color -o brwhite
  echo -n $USER
  set_color f0dd60
  echo -n " ::"
  set_color 4fafff
  if [ $PWD != $HOME ]
    echo -n " "(prompt_pwd)
  end

  if [ $pipestatus != 0 ]
    set_color -o brred
    echo -n "[$pipestatus]"
  end

  set_color 4c82b0
  echo -en " » \e[2 q"
end

function fish_greeting 
  # I don't need a greeting evertime thx.
end
