#!/bin/bash

app="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/build/app/tradeDataAnalyzer/tradeDataAnalyzer"
dataRoot="/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/data/tradingData"
tradingFiles=($(ls ${dataRoot}/*EURJPY*M1*.csv))
outputFolder="EURJPY_PDF"

for tradingFile in "${tradingFiles[@]}"
do
    outputFileName="$(basename ${tradingFile}).dis.csv"
    ${app} -f ${tradingFile} -o ${outputFileName} -t pdfBuilder
done

distributionFiles=($(ls *dis.csv))

for distributionFile in "${distributionFiles[@]}"
do
    echo "${distributionFile}"
    gnuplot -e "inputFile='${distributionFile}'" -e "outputFile='${distributionFile}.png'" makeGraph.plt
done

if [ ! -d ${outputFolder} ]; then
    mkdir ${outputFolder}
fi

mv *.dis.csv ${outputFolder}
mv *png ${outputFolder}
