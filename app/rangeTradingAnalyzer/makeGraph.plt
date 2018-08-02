if (!exists("inputFile")) inputFile = "EURJPY.H4.dis.txt"
if (!exists("outputFile")) outputFile = "EURJPY.H4.dis.png"

set title  'Support and Resistance distribution    ' . inputFile       # plot title
set xlabel 'Price'                                                     # x-axis label
set ylabel 'Occurance'                                                 # y-axis label
# key/legend
set key top right
set datafile separator ","

plot inputFile using 1:2 with boxes

set term png size 1680,1024
set output outputFile
replot