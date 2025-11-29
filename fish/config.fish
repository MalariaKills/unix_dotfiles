starship init fish | source

set -g fish_greeting ""

if status is-interactive; and test -t 1
    fastfetch
end
