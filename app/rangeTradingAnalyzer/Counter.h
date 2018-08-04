#ifndef COUNTER_H
#define COUNTER_H
#include <vector>
#include <string>
#include <sstream>
#include <unordered_map>
#include <algorithm>

#include "dataStruct.h"
#include "NLTime.h"
struct ResultData
{
    ResultData(int inPrice, int inOccurrence)
    {
        price = inPrice;
        occurrence = inOccurrence;
    };

    int price;
    int occurrence;
};

class Counter
{
 protected:
    std::vector<ResultData> m_countingResult;
    std::unordered_map<int, int> m_hashCounter; // key: price, value: occurrence
 public:
    enum class RangeType{MONTH, DAY, HOUR, MINUTE};
 public:
    Counter(){}
    virtual ~Counter(){}

    int DoCounting(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType);

    virtual void PrintResult(const std::string& outputFile, const ForexInfo& forexInfo);
    virtual std::string GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType) = 0;
 protected:
    virtual int DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime) = 0;
    void Convert2Result();
};

std::string RangeType2String(Counter::RangeType rangeType);
bool priceCompare(const ResultData& firstElem, const ResultData& secondElem);
bool occurrenceCompare(const ResultData& firstElem, const ResultData& secondElem);

#endif
