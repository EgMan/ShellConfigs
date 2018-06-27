alias start='cmd.exe /c start'
opendir() {
    `cd $1; start .`
}

