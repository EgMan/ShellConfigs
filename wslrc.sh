alias wsl='wsl.exe'
alias start='cmd.exe /c start'
alias powershell='powershell.exe'
alias ejectcd="power 'powershell (New-Object -com 'WMPlayer.OCX.7').cdromcollection.item(0).eject()' >/dev/null &"
alias controlpanel="power 'control panel' >/dev/null"
alias abortallshutdown='power "while(1){shutdown -a *>\$null; if(\$lastexitcode -eq 0){\$time = get-date -Format HH:mm:ss ; echo \"\`nSuccesfully aborted a shutdown (\$time)\"}}"'
alias chrome='"/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"'
alias origin='chrome `git config --get remote.origin.url`'
alias subl='"/mnt/c/Program Files/Sublime Text 3/sublime_text.exe"'
export DISPLAY=:0
opendir() {
    `cd $1; start .`
}
power(){
    powershell.exe <<done
$@
done
}
