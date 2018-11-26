#Local

#Aliases

#Sources
source $rc_path/bookmarks_cern

#Functions
cernerdns(){
    lookup=`host "$1.northamerica.cerner.net"`
    if [ $? -ne 0 ];then
        lookup=`host "$1.ip.devcerner.net"`
        if [ $? -ne 0 ];then
            echo "could not resolve"
            return 1
        fi
    fi
    echo $lookup | awk '{print $NF}'
}

cssh() {
    lookup=`cernerdns $1`
    if [ $? -ne 0 ];then
        echo $lookup
        return 1
    fi
    ssh aw055790@$lookup
}
