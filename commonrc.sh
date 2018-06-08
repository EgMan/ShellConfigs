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

bookmark() {
        typeCheck=$(type $1 &> /dev/null)
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
source `rc_path`/bookmarks

#Setups
cat ~/.vimrc | grep "source `rc_path`/vimrc.vim" &> /dev/null
if [ $? -ne 0 ]; then
	echo "source `rc_path`/vimrc.vim" >> ~/.vimrc
fi

#Aliases
alias commonrc="vim `rc_full`"
alias refresh="source `rc_full`"
alias bookmarks="vim `rc_path`/bookmarks"
alias vimrc="source `rc_path`/vimrc.vim"

#Exports
export HISTSIZE=$hist_size

#Sources
source `rc_path`/cernrc.sh


#Cleanup local
unset hist_size
