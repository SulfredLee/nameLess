#!/bin/bash

appRoot="/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/build/app/StepCounting"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/data/tradingData"

tradingFiles=($(ls ${dataRoot}/*M1.csv))

for tradingFile in "${tradingFiles[@]}"
do
    echo "StepCounting ${tradingFile}"
    outputFileName=$(basename ${tradingFile})
    ${appRoot}/StepCounting ${tradingFile} ${outputFileName} 2
done

distributionFiles=($(ls *dis.txt))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done
