bind \e accept-autosuggestion

abbr -a objdump "objdump -M intel -C"
abbr -a cat "bat"
abbr -a tree "tree --gitignore"

abbr -a l "eza -T -L 2"
abbr -a ls "eza"
abbr -a ll "eza -aghHl"

if command -q tree && command -q rg
    abbr -a tree "rg --files | tree --fromfile"
end

switch (uname)
    case Darwin
        abbr -a make "make -j$(math $(sysctl -n hw.physicalcpu) + 1)"
        abbr -a jupyter "jupyter lab --app-dir /opt/homebrew/share/jupyter/lab"
        abbr -a ninja "/Applications/'Binary Ninja.app'/Contents/MacOS/binaryninja"

        if command -q aria2c
            abbr -a aria2c "aria2c --enable-peer-exchange=true --enable-dht=true"
        end
    case Linux
        abbr -a make "make -j$(math $(nproc) + 1)"
        abbr -a jupyter "jupyter lab"

        export TERM="xterm"
        export XCURSOR_THEME="Adwaita"
        export GPG_TTY=$(tty)

        # Fix ghidra gray screen on wayland
        export _JAVA_AWT_WM_NONREPARENTING="1"

        if command -q aria2c
            abbr -a aria2c "aria2c --async-dns=false --enable-peer-exchange=true --enable-dht=true"
        end
end

if command -q nvim
    set EDITOR nvim
else
    set EDITOR vim
end

set PYTHON3_HOST_PROG "/usr/bin/python3"

# colored man output
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

function modus-vivendi -d "Emacs modus contrast theme"
    set -l foreground ffffff # fg-main
    set -l comment a8a8a8 # fg-alt
    set -l selection 34cfff # blue-active

    # *-intense color
    set -l red fe6060
    set -l orange fba849
    set -l green 4fe42f
    set -l yellow f0dd60
    set -l blue 4fafff
    set -l magenta ff62d4
    set -l purple 9f80ff
    set -l cyan 3fdfd0

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $purple
    set -g fish_color_keyword $magenta
    set -g fish_color_quote $blue
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_error $red
    set -g fish_color_param $cyan
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $magenta
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment

    # remember current theme
    set -U base16_theme gruvbox-dark-medium

    # clean up
    functions -e put_template put_template_var put_template_custom
end

if status --is-interactive
  modus-vivendi
  if command -q direnv
    direnv hook fish | source
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

  set_color 4c82b0
  echo -en " » \e[2 q"
end

function fish_greeting 
  # I don't need a greeting evertime thx.
end
