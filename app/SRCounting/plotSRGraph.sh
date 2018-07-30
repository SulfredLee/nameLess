#!/bin/bash

appRoot="/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/build/app/SRCounting"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/data/tradingData"

tradingFiles=($(ls ${dataRoot}/*H4.csv))

for tradingFile in "${tradingFiles[@]}"
do
    outputFileName=$(basename ${tradingFile})
    ${appRoot}/SRCounting ${tradingFile} ${outputFileName}
done

distributionFiles=($(ls *dis.txt))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done
