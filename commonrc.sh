#Local
hist_size=1000000
loading_bar_size=7
loading_bar_current=1

#Functions
clear_loading_bar(){
    for i in `seq $loading_bar_size`; do
        echo -ne '\b'
    done
}
render_loading_bar(){
    if [ $loading_bar_current -ne 0 ]; then
        clear_loading_bar
    fi
    for i in `seq $loading_bar_size`; do
        if [ $i -le $loading_bar_current ];then
            echo -ne '█'
        else
            echo -ne '░'
        fi
    done
    loading_bar_current=$((loading_bar_current + 1))
}; render_loading_bar
rc_full() {
    #ret= `realpath $BASH_SOURCE`
    #[ -z "$ret" ] && ret=${0:a}
    #echo $ret

    #TODO FIX THIS HARDCODING
    echo "/home/aw055790/.rc/commonrc.sh"
}
rc_path() {
    echo $(dirname `rc_full`)
}
rc_name() {
    echo $(basename `rc_full`)
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
        echo $makeAlias >> `rc_path`/bookmarks
        echo "Saved to `rc_path`/bookmarks"
        eval ${makeAlias}
}

#Tmux
render_loading_bar
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

#Argument parsing
render_loading_bar
force_setup=1
while [[ $# -gt 0 ]]; do
    case "$1" in
        -setup | -s)
            force_setup=1
            echo "forcing setup"
        ;;
    esac
    shift 1
done

#One time setup
render_loading_bar
if [ ! -f `rc_path`/.deleteme_to_rerun_setup ] || [ $force_setup -eq 1 ];then
    [ ! -f ~/.vimrc ] && touch ~/.vimrc
    cat ~/.vimrc | grep "source `rc_path`/vimrc.vim" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "source `rc_path`/vimrc.vim" >> ~/.vimrc
    fi
    
    [ ! -f ~/.tmux.conf ] && touch ~/.tmux.conf
    cat ~/.tmux.conf | grep "source-file `rc_path`/tmux.conf" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "source-file `rc_path`/tmux.conf" >> ~/.tmux.conf 
    fi
    
    [ -d ~/.oh.my.zsh ] && ln -sf  `rc_path`/nahmsayin_prompt.zsh-theme ~/.oh-my-zsh/themes/nahmsayin_prompt.zsh-theme
    
    [ ! -d ~/.vim/swp ] && mkdir -p ~/.vim/swap
    [ ! -d ~/.vim/undo ] && mkdir -p ~/.vim/undo
    [ ! -d ~/.vim/backup ] && mkdir -p ~/.vim/backup

    touch `rc_path`/.deleteme_to_rerun_setup
fi

#Aliases
render_loading_bar
alias commonrc="vim `rc_full`"
alias refresh="source `rc_full`"
alias bookmarks="vim `rc_path`/bookmarks"
alias vimrc="vim `rc_path`/vimrc.vim"
alias tmuxconf="vim `rc_path`/tmux.conf"
alias zrefresh="source ~/.zshrc"
alias brefresh="source ~/.bashrc"
alias nahmsayin="vim `rc_path`/nahmsayin_prompt.zsh-theme"

#Exports
export HISTSIZE=$hist_size

#Sources
render_loading_bar
source `rc_path`/cernrc.sh
source `rc_path`/wslrc.sh
source `rc_path`/bookmarks

#Cleanup local
render_loading_bar
unset hist_size
unset force_setup
unset loading_bar_current
clear_loading_bar
