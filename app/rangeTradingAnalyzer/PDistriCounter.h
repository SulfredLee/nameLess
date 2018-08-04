#ifndef PDISTRICOUNTER_H
#define PDISTRICOUNTER_H
#include "Counter.h"
#include "dataStruct.h"

class PDistriCounter : public Counter
{
 public:
    PDistriCounter();
    ~PDistriCounter();
 private:
    int DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime);
    void CountAPrice(int lowPrice, int highPrice);
};
#endif
