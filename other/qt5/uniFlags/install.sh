#!/bin/bash
dstPath="/mnt/c/Users/sflee/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5"
ProjectName="uniFlags"
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

if [ "${ACTION}" == "install" ]; then
    cp -r "Indicators/${ProjectName}" "${dstPath}/Indicators"
elif [ "${ACTION}" == "clean" ]; then
    rm -rf "${dstPath}/Indicators/${ProjectName}"
fi
