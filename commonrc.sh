#Local
hist_size=1000000

#Functions
rc_full() {
    echo `realpath $BASH_SOURCE`
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

#Aliases
alias commonrc="vim `rc_full`"
alias refresh="source `rc_full`"
alias bookmarks="vim `rc_path`/bookmarks"
alias vimrc="vim `rc_path`/vimrc.vim"
alias tmuxconf="vim `rc_path`/tmux.conf"

#Exports
export HISTSIZE=$hist_size

#Sources
source `rc_path`/cernrc.sh
source `rc_path`/wslrc.sh
source `rc_path`/bookmarks


#Cleanup local
unset hist_size
