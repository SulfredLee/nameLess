#include "SRCounter.h"
#include "Logger.h"

SRCounter::SRCounter()
{}

SRCounter::~SRCounter()
{}

int SRCounter::DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime)
{
    int nextIdx = -1;
    m_hashCounter.clear();
    size_t i = startIdx;
    for (; i < inData.size() && inData[i].time < endTime; i ++)
    {
        CountAPrice(inData[i].high);
        CountAPrice(inData[i].low);
    }

    Convert2Result();

    if (i >= inData.size())
    {
        nextIdx = -1;
    }
    else
    {
        nextIdx = i;
    }
    return nextIdx;
}

void SRCounter::CountAPrice(int price)
{
    auto it = m_hashCounter.find(price);
    if (it == m_hashCounter.end())
    {
        m_hashCounter.insert(std::make_pair(price, 1));
    }
    else
    {
        it->second++;
    }
}
