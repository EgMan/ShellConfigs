#Local
self=`realpath $BASH_SOURCE`
path=`dirname $self`
name=`basename $self`

#Aliases
alias commonrc="vim $self"
alias refresh="source $self"
alias bookmarks="vim $path/bookmarks"
alias vimrc="source $path/vimrc.vim"

#Sources
source ${path}/cernrc.sh

#Functions
bookmark() {
        typeCheck=$(type $1)
        if [ $? -eq 0 ]; then
                echo "Name collision.  Can't make bookmark."
                echo $typeCheck
                return
        fi
        makeAlias="alias $1='cd $(pwd)'"
        echo $makeAlias
	echo ${path}/bookmarks
        echo $makeAlias >> ${path}/bookmarks
        eval ${makeAlias}
}
source ${path}/bookmarks

#Setups
cat ~/.vimrc | grep "source ${path}/vimrc.vim" &> /dev/null
if [ $? -ne 0 ]; then
	echo "source ${path}/vimrc.vim" >> ~/.vimrc
fi

unset self path name
