#!/bin/bash

app="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/build/app/tradeDataAnalyzer/tradeDataAnalyzer"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/data/tradingData"
tradingFiles=($(ls ${dataRoot}/*EURJPY*M1*.csv))
outputFolder="EURJPY_MVCLS"
fileExt="*.slopePDF.csv"
fileExt002="*.movingAvg.csv"
fileExt003="*.diffPDF.csv"

for tradingFile in "${tradingFiles[@]}"
do
    outputFileName="$(basename ${tradingFile})"
    ${app} -f ${tradingFile} -o ${outputFileName} -t movingClose
done

distributionFiles=($(ls ${fileExt} ${fileExt003}))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done

if [ ! -d ${outputFolder} ]; then
    mkdir ${outputFolder}
fi

mv ${fileExt} ${outputFolder}
mv ${fileExt002} ${outputFolder}
mv ${fileExt003} ${outputFolder}
mv *png ${outputFolder}
