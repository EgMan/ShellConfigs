alias start='cmd.exe /c start'
export DISPLAY=:0
opendir() {
    `cd $1; start .`
}

