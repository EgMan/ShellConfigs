#Local
hist_size=1000000

#Functions
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

#Setups
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

[ ! -d ~/.vimundodir ] && mkdir ~/.vimundodir

if [[ "$TERM" != "screen" ]] && 
        [[ "$SSH_CONNECTION" == "" ]]; then
    # Attempt to discover a detached session and attach 
    # it, else create a new session
    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
        tmux -2 attach-session -t $WHOAMI
    else
        tmux -2 new-session -s $WHOAMI
    fi
else
    echo "Screen is garbage.  Use tmux instead."
fi

#Aliases
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
source `rc_path`/cernrc.sh
source `rc_path`/wslrc.sh
source `rc_path`/bookmarks

#Cleanup local
unset hist_size
