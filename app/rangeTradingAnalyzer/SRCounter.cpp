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
        // int shift = -20;
        // for (int j = 0; j < 40; j++)
        // {
        //     CountAPrice(inData[i].high + shift);
        //     CountAPrice(inData[i].low + shift);
        // }
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

std::string SRCounter::GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType)
{
    std::stringstream ss;
    ss << inputFile << "." << startTime.toString("%Y.%m.%d") << "_" << endTime.toString("%Y.%m.%d") << "." << RangeType2String(rangeType) << ".dis.csv";
    return ss.str();
}
