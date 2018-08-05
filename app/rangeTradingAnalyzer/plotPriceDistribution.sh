#!/bin/bash

appRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/build/app/rangeTradingAnalyzer"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/data/tradingData"

tradingFiles=($(ls ${dataRoot}/*H4.csv))


for tradingFile in "${tradingFiles[@]}"
do
    outputFileName=$(basename ${tradingFile})
    ${appRoot}/rangeTradingAnalyzer -f ${tradingFile} -o ${outputFileName} -t PDistriCounter
done

distributionFiles=($(ls *dis.csv))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done
