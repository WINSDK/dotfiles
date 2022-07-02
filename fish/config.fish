bass source /etc/profile

abbr -a cat bat
abbr -a aria2c "aria2c --enable-dht=true"
abbr -a hexdump "hexdump -C"
abbr -a l "exa -T -L 2"
abbr -a ls "exa"
abbr -a ll "exa -aghHl"
abbr -a tree "rg --files | tree --fromfile"

switch (uname)
    case Linux
        abbr -a camera "mpv av://v4l2:/dev/video0"
        abbr -a objdump "objdump -M intel -C"
        abbr -a packages "emerge -epv @world | rg -o '\[ebuild   R    \] (.*)::gentoo  USE' -r '\$1'"
    case '*'
        abbr -a objdump "objdump -x86-asm-syntax=intel -C"
end

fish_add_path -P ~/.local/bin
fish_add_path -P ~/.cargo/bin
fish_add_path -P ~/Projects/utils
fish_add_path -P ~/Projects/utils/git-size/target/release

export GPG_TTY=$(tty)
set EDITOR nvim
set TERM screen-256color
set PYTHON_HOST_PROG "/usr/bin/python2"
set PYTHON3_HOST_PROG "/usr/bin/python3"
set LLVM_HOME "/usr/lib/llvm/14"

# colored man output
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR -eq 1
    exec startx > /var/log/i3.log 2>&1
  end
end

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
  echo -n " » "
end

function fish_greeting 
  # I don't need a greeting evertime thx.
end
