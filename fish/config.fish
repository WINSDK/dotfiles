abbr -a cat bat
abbr -a aria2c "aria2c --enable-dht=true"
abbr -a hexdump "hexdump -C"
abbr -a l "exa -T -L 2"
abbr -a ls "exa"
abbr -a ll "exa -aghHl"
abbr -a tree "rg --files | tree --fromfile"
abbr -a objdump "objdump -x86-asm-syntax=intel -C"
abbr -a ssh "kitty +kitten ssh"

fish_add_path ~/.cargo/bin
fish_add_path /usr/local/Cellar/llvm/*/bin
fish_add_path ~/Projects/utils
fish_add_path ~/Projects/utils/git-size/target/release

set EDITOR nvim
set PYTHON_HOST_PROG "/usr/bin/python2"
set PYTHON3_HOST_PROG "/usr/bin/python3"
set FISH_CLIPBOARD_CMD "bat"

set LLVM_HOME "/usr/local/Cellar/llvm/13.0.0_2"
set LLVM_BUILD "/usr/local/Cellar/llvm/13.0.0_2"

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
  echo -n (users)
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
