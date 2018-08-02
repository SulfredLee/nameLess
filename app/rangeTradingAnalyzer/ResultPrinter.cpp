#include "ResultPrinter.h"

#include <fstream>
ResultPrinter::ResultPrinter()
{}

ResultPrinter::~ResultPrinter()
{}

void ResultPrinter::Print(const std::string& outputFile, const std::vector<ResultData>& resultData, const ForexInfo& forexInfo)
{
    std::ofstream FH(outputFile.c_str());
    for (size_t i = 0; i < resultData.size(); i++)
    {
        FH << resultData[i].price / static_cast<double>(forexInfo.shifter) << "," << resultData[i].occurrence << std::endl;
    }
    FH.close();
}
