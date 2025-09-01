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
