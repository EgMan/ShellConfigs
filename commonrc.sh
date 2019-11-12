#Local
hist_size=1000000
loading_bar_size=6
loading_bar_current=0

#Fix for zsh's background process bug
[ ! -z $ZSH_NAME ] && unsetopt BG_NICE
[ ! -z $ZSH_NAME ] && setopt histignorespace
[ ! -z $BASH_VERSION ] && export rc_full=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/$(basename ${BASH_SOURCE[0]} 2>/dev/null)
[ ! -z $ZSH_VERSION ] && export rc_full=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")") 
export rc_path=`dirname $rc_full`
export rc_name=`basename $rc_full`


#Functions
query_cursor_row(){
    stty -echo
    echo -n $'\e[6n'
    read -d R x 
    stty echo
    #This global state bullshit is a dumb workaround for the fact that this means of 
    #querying for cursor position can't run in a subshell.  
    #therefore it can't be set or read into a variable
    #change this if another way is found. 
    cursor_row=$((`echo -n ${x#??} | awk -F';' '{print $1}'`-1))
}
clear_loading_bar(){
    query_cursor_row
    tput sc
    tput cup $loading_bar_pos 0
    [ $cursor_row -eq $((loading_bar_pos+1)) ] && tput sc
    clear_size=$((loading_bar_size+6))
    printf "%${clear_size}s" ""
    tput rc
}
render_loading_bar(){
    if [ $loading_bar_current -eq 0 ]; then
        query_cursor_row
        loading_bar_pos=$cursor_row
        [ $cursor_row -lt $((`tput lines`-1)) ] && echo ''
    fi
    tput sc
    tput cup $loading_bar_pos 0
    for i in `seq 0 $(($loading_bar_size - 1))`; do
        if [ $i -lt $loading_bar_current ];then
            echo -n '█'
        else
            echo -n '░'
        fi
    done
    echo -n " ${loading_bar_current}/${loading_bar_size}"
    tput rc
    loading_bar_current=$((loading_bar_current + 1))
}; render_loading_bar


rc_full_func() {
    #ret= `realpath $BASH_SOURCE`
    #[ -z "$ret" ] && ret=${0:a}
    #echo $ret

    #TODO FIX THIS HARDCODING
    #echo "/home/aw055790/.rc/commonrc.sh"
     #[ ! -z $BASH_VERSION ] && echo $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/$(basename ${BASH_SOURCE[0]} 2>/dev/null)
     #[ ! -z $ZSH_VERSION ] && echo $(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")") 
     

    echo $rc_full
}

rc_path_func() {
    echo $(dirname ${rc_full})
}
export rc_path_var=${rc_path}

rc_name_func() {
    echo $(basename ${rc_full})
}
display_tmux_joke(){
    if [ ! -z $TMUX ]; then
        #joke=`curl -s https://icanhazdadjoke.com/`
        joke=`curl -s 'https://geek-jokes.sameerkumar.website/api' | sed -e 's/^"//' -e 's/"$//'`
        [ $? -ne 0 ] && return
        grepres=`tmux show-options -g | grep display-panes-time`
        if [ $? -ne 0 ]; then
            dispPanesTime=3000
        else
            dispPanesTime=`echo $grepres | awk '{print $2}'`
        fi
        tmux set-option -g display-time 10000
        tmux display-message $joke
        tmux set-option -g display-time $dispPanesTime
    fi
}

monitor_packet_quality(){
    echo -- > ${rc_path}/.packet_quality
    echo -n -------------------- > ${rc_path}/.packet_responses
    which fping >/dev/null
    fpingins=$?
    while :; do
        if [ $fpingins -eq 0 ]; then
            dumbworkaround=`fping -c 1 8.8.8.8 2>/dev/null`
            result=$?
        else 
            dumbworkaround=`ping -W 1 -c 1 8.8.8.8 2>/dev/null`
            result=$?
        fi
        [ $result -eq 0 ] && reachable=1 || reachable=0
        echo -n $reachable >> ${rc_path}/.packet_responses
        #cat ${rc_path}/.packet_responses
        sed -i 's/^.//' ${rc_path}/.packet_responses
        s=$(grep -o '1' ${rc_path}/.packet_responses | wc -l)
        f=$(grep -o '0' ${rc_path}/.packet_responses | wc -l)
        if [ $((s+f)) -eq 0 ]; then
            packet_quality="--"
        else
            packet_quality=`echo "100*$s/($s+$f)" | bc -l | sed 's/\..*//'`
        fi
        echo $packet_quality > ${rc_path}/.packet_quality
    done
    #old (slower) way
    #while :; do
    #    packet_quality=$((100 - $(grep -oP '\d+(?=%)' <<< $(ping -c 10 8.8.8.8 2>/dev/null)))) 
    #    echo $packet_quality > ${rc_path}/.packet_quality
    #done
} 
[ -z $TMUX ] && [ -z $no_tmux ] || [ $no_tmux -eq 0 ] && monitor_packet_quality &

tmux_colors(){
    for i in {0..255}; do
            printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}
tmux_color(){
    printf "\x1b[38;5;${1}m"
}

vimf() {
    results=`find . -name "$1"`
    resultsCount=`echo $results | wc -l`
    firstResult=`echo $results | head -1`
    message="$resultsCount result(s) found.  Editing: $firstResult"
    echo $message
    vim $firstResult
}
rmswp(){
    rm ~/.vim/swap/*
}
mkdircd(){
    mkdir $1 && cd $1
}
saveref(){
    date=`date '+%Y-%m-%d %H:%M:%S'`
    msg="Save (${date})"
    [ -z "$1" ] || msg="${msg}: $1"
    git commit -am "$msg" >/dev/null && git reset HEAD~1 >/dev/null && echo $msg || echo "Unsuccessful"
}

#Todo: accept optional argument to save to alternate file
#Todo: save files to subdirectory
bookmark() {
        typeCheck=$(type $1 2>&1)
        if [ $? -eq 0 ]; then
                echo "Name collision.  Can't make bookmark."
                echo $typeCheck
                return
        fi
        makeAlias="alias $1='cd $(pwd)'"
        echo $makeAlias
        echo $makeAlias >> ${rc_path}/bookmarks
        echo "Saved to ${rc_path}/bookmarks"
        eval ${makeAlias}
}

#Argument parsing
render_loading_bar
force_setup=0
no_tmux=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -setup | -s)
            force_setup=1
        ;;
        -notmux | -n)
            no_tmux=1
        ;;
    esac
    shift 1
done

#Tmux
render_loading_bar
if [ $no_tmux -eq 0 ]; then
    if [ -z $TMUX ]; then
        if [[ "$TERM" == "screen" ]]; then
            echo "Screen is garbage.  Use tmux instead."
        elif [[ "$SSH_CONNECTION" != "" ]]; then
            echo "SSH Connection detected.  Not attaching tmux session."
        else
            #Attempt to discover a detached session and atta it,
            #else create a new session
            WHOAMI=$(whoami)
            if tmux has-session -t $WHOAMI 2>/dev/null; then
                tmux -2 attach-session -t $WHOAMI
            else
            tmux -2 new-session -s $WHOAMI
            fi
        fi
    fi
fi

#One time setup
render_loading_bar
if [ ! -f ${rc_path}/.deleteme_to_rerun_setup ] || [ $force_setup -eq 1 ];then
    echo "Running setup"
    depsfound=1
    which tmux >/dev/null || {tput setaf 1; echo "Please install tmux"; depsfound=0 }
    which vim >/dev/null || {tput setaf 1; echo "Please install vim"; depsfound=0 }
    which fping >/dev/null || {tput setaf 1; echo "Please install fping"; depsfound=0 }
    which zsh >/dev/null || {tput setaf 3; echo "While this config should work with bash, you're missing out on the zsh. You should install zsh.  It's better."}
    [ ! -f ~/.vimrc ] && touch ~/.vimrc
    [ ! -f ${rc_path}/bookmarks ] && touch ${rc_path}/bookmarks
    cat ~/.vimrc | grep "^source ${rc_path}/vimrc.vim$" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "source ${rc_path}/vimrc.vim" >> ~/.vimrc
    fi
    
    [ ! -f ~/.tmux.conf ] && touch ~/.tmux.conf
    cat ~/.tmux.conf | grep "source-file ${rc_path}/tmux.conf" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "source-file ${rc_path}/tmux.conf" >> ~/.tmux.conf 
    fi

    [ ! -f ~/.bashrc ] && touch ~/.bashrc
    cat ~/.bashrc | grep "source ${rc_full}" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Adding bashrc entry"
        echo "source ${rc_full}" >> ~/.bashrc 
    fi

    [ ! -f ~/.zshrc ] && touch ~/.zshrc
    cat ~/.zshrc | grep "source ${rc_full}" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Adding zshrc entry"
        echo "source ${rc_full}" >> ~/.zshrc 
    fi
    
    [ -d ~/.oh-my-zsh ] && ln -sf  ${rc_path}/nahmsayin_prompt.zsh-theme ~/.oh-my-zsh/themes/nahmsayin_prompt.zsh-theme
    
    [ ! -d ~/.vim/swp ] && mkdir -p ~/.vim/swap
    [ ! -d ~/.vim/undo ] && mkdir -p ~/.vim/undo
    [ ! -d ~/.vim/backup ] && mkdir -p ~/.vim/backup

    [ $depsfound -ne 0 ] && touch ${rc_path}/.deleteme_to_rerun_setup
fi

#Aliases
render_loading_bar
alias commonrc="vim ${rc_full}"
alias refresh="source ${rc_full}"
alias bookmarks="vim ${rc_path}/bookmarks"
alias vimrc="vim ${rc_path}/vimrc.vim"
alias tmuxconf="vim ${rc_path}/tmux.conf"
alias zrefresh="source ~/.zshrc"
alias brefresh="source ~/.bashrc"
alias nahmsayin="vim ${rc_path}/nahmsayin_prompt.zsh-theme"
alias please="sudo"

#Exports
export HISTSIZE=$hist_size

#Sources
render_loading_bar
source ${rc_path}/cernrc.sh
source ${rc_path}/wslrc.sh
source ${rc_path}/bookmarks

#Cleanup local
render_loading_bar
unset hist_size
unset force_setup
unset loading_bar_current
clear_loading_bar

#Asynchronous process startup
(display_tmux_joke &) 
