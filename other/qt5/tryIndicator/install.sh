#!/bin/bash
sourceFiles=($(ls *mqh *mq5))
dstPath="/mnt/c/Users/sflee/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5"
appFolder="Indicators/tryIndicator"
sourcePath="$PWD"

# get input argument
while getopts a:h: option
do
    case "${option}"
    in
        a) ACTION=${OPTARG};;
        h) HELP=${OPTARG};;
    esac
done

if [ -z $ACTION ]; then
    echo "Usage: $0 -a [install|clean]"
    exit
fi

actionProxy() {
    args=("$@")
    action="${args[0]}"
    folder="${args[1]}"
    files=("${args[@]:2}")

    if [ ! -d ${dstPath}/${folder} ]; then
        mkdir -p ${dstPath}/${folder}
    fi

    for file in "${files[@]}"
    do
        if [ "${action}" == "cp" ]; then
            ${action} ${sourcePath}/${file} ${dstPath}/${folder}
        elif [ "${action}" == "rm" ]; then
            ${action} ${dstPath}/${folder}/${file}
        fi
    done
}

if [ "${ACTION}" == "install" ]; then
    actionProxy "cp" "${appFolder}" "${sourceFiles[@]}"
elif [ "${ACTION}" == "clean" ]; then
    actionProxy "rm" "${appFolder}" "${sourceFiles[@]}"
fi
