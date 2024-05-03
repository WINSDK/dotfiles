bind \e accept-autosuggestion

abbr -a lldb "rust-lldb"
abbr -a gdb "rust-gdb"
abbr -a objdump "objdump -M intel -C"

if command -q bat
    abbr -a cat "bat"
end

if command -q hexdump
    abbr -a hexdump "hexdump -C"
end

if command -q exa
    abbr -a l "exa -T -L 2"
    abbr -a ls "exa"
    abbr -a ll "exa -aghHl"
end

if command -q tree && command -q rg
    abbr -a tree "rg --files | tree --fromfile"
end

switch (uname)
    case Darwin
        set -U fish_user_paths /opt/homebrew/bin/ $fish_user_paths
        abbr -a make "bear -- make -j$(math $(sysctl -n hw.physicalcpu) + 1)"
        abbr -a jupyter "jupyter lab --app-dir /opt/homebrew/share/jupyter/lab"

        if command -q aria2c
            abbr -a aria2c "aria2c --enable-dht=true"
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
            abbr -a aria2c "aria2c --async-dns=false --enable-dht=true"
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
  if type -q base16-gruvbox-dark-medium
    base16-gruvbox-dark-medium
  end
end

function fish_prompt
  set_color -o brwhite
  echo -n $USER
  set_color red
  echo -n " ::"
  set_color yellow
  if [ $PWD != $HOME ]
    echo -n " "(prompt_pwd)
  end

  if [ $pipestatus != 0 ]
    set_color -o brred
    echo -n "[$pipestatus]"
  end

  set_color blue
  echo -en " » \e[2 q"
end

function fish_greeting 
  # I don't need a greeting evertime thx.
end
