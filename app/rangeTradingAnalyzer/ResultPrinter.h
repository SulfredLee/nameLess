#ifndef RESULTPRINTER_H
#define RESULTPRINTER_H
#include "Counter.h"
#include "dbBuilder.h"

#include <vector>
class ResultPrinter
{
 public:
    ResultPrinter();
    ~ResultPrinter();

    void Print(const std::string& outputFile, const std::vector<ResultData>& resultData, const ForexInfo& forexInfo);
};
#endif
