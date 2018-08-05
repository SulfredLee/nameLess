#!/bin/bash
mkdir convertDB
inputFiles=($(ls *.csv))
for inputFile in "${inputFiles[@]}"
do
    echo "${inputFile}"
    iconv -f UCS-2LE -t UTF-8 ${inputFile} >> ./convertDB/${inputFile}
done
