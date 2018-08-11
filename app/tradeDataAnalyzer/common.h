#ifndef COMMON_H
#define COMMON_H
#include <vector>

#include "dataStruct.h"

namespace Common
{
    std::vector<OHLC> GetOHLCFrom(const std::string& dataFile);
    std::string OHLCToString(const OHLC& inOHLC);
    double DenormalizeDouble(int inNum, int digits);
};
#endif
