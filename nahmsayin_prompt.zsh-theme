alias echo='echo -n'

function permission_icon {
    echo "%{$fg[yellow]%}♙ "
}

function prompt_for_command {
    echo "\n( !%! )-> "
}

function better_git_prompt_info {
    git rev-parse --is-inside-work-tree &> /dev/null
    if [ $? -eq 0 ];then
        branch=$(git branch | grep '^*' | sed 's/* //' )
        color="%{$bg[white]%}"
        if [ `git status -sb | wc -l` -le 1 ]; then
            color="${color}%{$fg[black]%}"
        else
            color="${color}%{$fg[red]%}"
        fi
        echo " ${color} ${branch} %{$reset_color%}"
    fi
}

function job_info {
    local suspended=$(jobs -sp | wc -l)
    local running=$(jobs -rp | wc -l)
    color="%{$bg[blue]%}"
    [ $running -gt 0 ] && echo " ${color} %{$fg[green]%}${running} running %{$reset_color%}"
    [ $suspended -gt 0 ] && echo " ${color} %{$fg[red]%}${suspended} suspended %{$reset_color%}"
}

local sep="%{$fg[white]%}:"
local user="%{$fg[blue]%}%n"
local location="%{$fg[green]%}%~"
local ret_status="%{$fg[white]%}(%(?:%{$fg_bold[green]%}0:%{$fg_bold[red]%}%?)%{$fg[white]%})"

PROMPT='$(permission_icon)${sep}${user}${sep}${location}${sep}${ret_status}$(better_git_prompt_info)$(job_info)$(prompt_for_command)'

unalias echo
