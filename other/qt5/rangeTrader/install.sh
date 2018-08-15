#!/bin/bash
# headerFiles=( CFractalPoint.mqh cisnewbar.mqh )
# expertFiles=( channelsplotter.mq5 testFractalPoint.mq5 )
# indicatorFiles=( x-bars_fractals.mq5 testIndicator.mq5 )
headerFiles=( SRLineManager.mqh SRTracker.mqh LimitOrder.mqh triggerManager.mqh )
expertFiles=( rangeTrader.mq5 )
indicatorFiles=( )
dstPath="/mnt/c/Users/sflee/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5"
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
    actionProxy "cp" "Include" "${headerFiles[@]}"
    actionProxy "cp" "Experts" "${expertFiles[@]}"
    actionProxy "cp" "Indicators" "${indicatorFiles[@]}"
elif [ "${ACTION}" == "clean" ]; then
    actionProxy "rm" "Include" "${headerFiles[@]}"
    actionProxy "rm" "Experts" "${expertFiles[@]}"
    actionProxy "rm" "Indicators" "${indicatorFiles[@]}"
fi
