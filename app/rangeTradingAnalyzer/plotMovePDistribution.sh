#!/bin/bash

appRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/build/app/rangeTradingAnalyzer"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/data/tradingData"

# tradingFiles=($(ls ${dataRoot}/*M1.csv))
tradingFiles=($(ls ${dataRoot}/EURJPY.M1.csv))


for tradingFile in "${tradingFiles[@]}"
do
    outputFileName=$(basename ${tradingFile})
    ${appRoot}/rangeTradingAnalyzer -f ${tradingFile} -o ${outputFileName} -t MPDistriCounter
done

# distributionFiles=($(ls *dis.csv))
distributionFiles=($(ls *full.csv))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done

distributionFiles=($(ls *one.csv))
for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done
