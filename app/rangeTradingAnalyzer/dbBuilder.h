#ifndef DBBUILDER_H
#define DBBUILDER_H
#include "dataStruct.h"

#include <vector>
#include <string>
class DBBuilder
{
 private:
    ForexInfo m_forexInfo;
    std::vector<OHLC> m_OHLCs;
 public:
    DBBuilder(const std::string& inFile);
    ~DBBuilder();

    ForexInfo& GetInfo();
    std::vector<OHLC>& GetOHLCs();
 private:
    OHLC MakeOHLC(const std::vector<std::string>& inData);
    int ShiftByDigit(const std::string& inValue);
};
#endif
