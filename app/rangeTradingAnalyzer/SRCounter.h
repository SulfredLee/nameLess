#ifndef SRCOUNTER_H
#define SRCOUNTER_H
#include "Counter.h"
#include "dataStruct.h"

class SRCounter : public Counter
{
 public:
    SRCounter();
    ~SRCounter();

 private:
    int DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime);
    void CountAPrice(int price);
};
#endif
